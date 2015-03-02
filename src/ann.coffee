converter = require('color-convert')()
_ = require 'lodash'
math = require 'mathjs'
convnet = require 'convnetjs'
brain = require 'brain'
Promise = require 'promise'

# Simple wrapper of convnet for color schemes
#
# @example cons
#     ann = new ANN()
#     ann.train(cocolourData)
#     ann.run(scheme)
#
class ANN

    # Costructor
    #
    constructor: (options = {}) ->

        # defaults =
        #     errorThresh: 0.2 # error threshold to reach
        #     iterations: 100 # max training iterations
        #     learningRate: 0.05

        defaults =
            iterations: 15
            learningRate: 0.05

        layers = [
            # input: 5 colors * 1 * [H, S, L]
            {type: 'input', out_sx: 15, out_sy: 1, out_depth: 1},

            # fully connected layers
            {type: 'fc', num_neurons: 15, activation: 'sigmoid'},

            # output probabilities
            # {type: 'softmax', num_classes: 2}

            # simple binary SVM classifer
            {type: 'svm', num_classes: 2}
        ]

        @net = new convnet.Net()
        @net.makeLayers layers

        @options = _.defaults options, defaults

        @trainer = new convnet.Trainer(@net, {learning_rate: @options.learningRate})


    # Convert [[R, G, B], ] to target vector
    #
    # @param [Array] scheme array of RGB Array
    #
    preprocess: (colors) ->

        hslMatrix = colors.map (rgb) ->
            # convert rgb to hsl
            hsl = converter.rgb(rgb).hsl()

            # normalize hsl to [0, 1]
            hsl.map (elem, index) ->
                if index is 0
                    elem /= 360
                else
                    elem /= 100
                parseFloat elem.toFixed(3)

        vector = _.flatten(hslMatrix)

        new convnet.Vol(vector)

    # Train data
    #
    # @param [Array] data cocolour style data [{rgbColors, score}]
    # @note this method can only be called once
    #
    train: (data) ->
        trainLabels = data.map (scheme) ->
            # 0 for positive and 1 for nagative
            if scheme.score > 0 then 0 else 1

        trainData = data.map (scheme) => @preprocess scheme.colors

        for __ in [0..@options.iterations]
            trainData.forEach (data, i) =>
                @trainer.train data, trainLabels[i]

        new Promise((resolve, reject) -> resolve())

    # Verify data
    #
    # @param [Array] data cocolour style data [{rgbColors, score}]
    #
    verify: (data) ->
        getResults = (data) =>
            tests = data.map (scheme) =>
                rate = @rate scheme
                scheme.score * rate > 0 # 同号，表明判断相同
            passed = (tests.filter (elem) -> elem).length
            rate = passed / tests.length
            {total: tests.length, passed: passed, rate: rate}
        res =
            all: getResults(data)
            positive: getResults(data.filter (scheme) -> scheme.score > 0)
            negative: getResults(data.filter (scheme) -> scheme.score < 0)

    # Rate given scheme
    #
    # @param [Object] data cocolour style data {rgbColors, score}
    # @return [Float] [-1, 1] {1: like, 0: normal, -1: dislike}
    #
    rate: (scheme) ->
        input = @preprocess scheme.colors
        w = @net.forward(input).w
        positive = w[0]
        negative = w[1]
        positive - negative
        # if positive > negative then positive else -negative

module.exports = ANN
