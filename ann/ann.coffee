converter = require("color-convert")()
brain = require 'brain'
_ = require 'lodash'
math = require 'mathjs'

# Simple wrapper of brain for color schemes
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

        defaults =
            errorThresh: 0.005 # error threshold to reach
            iterations: 30000 # max training iterations
            log: true
            logPeriod: 10
            learningRate: 0.3

        @options = _.defaults options, defaults
        @net = new brain.NeuralNetwork()

    # Convert data to hsl vector
    #
    # @param [Array] data cocolour style data [{rgbColors, score}]
    #
    preprocess: (data) ->
        data.map (scheme) ->
            hslMatrix = scheme.colors.map (rgb) ->
                # convert rgb to hsl
                hsl = converter.rgb(rgb).hsl()

                # normalize hsl to [0, 1]
                hsl.map (elem, index) ->
                    if index is 0
                        elem /= 360
                    else
                        elem /= 100
                    parseFloat elem.toFixed(3)

            input = _.flatten(hslMatrix)

            # 方差
            # hVar = math.var (hslMatrix.map (hsl) -> hsl[0])
            # sVar = math.var (hslMatrix.map (hsl) -> hsl[1])
            # vVar = math.var (hslMatrix.map (hsl) -> hsl[2])

            # input = input.concat(hVar, sVar, vVar)

            {input: input, output: if scheme.score > 0 then {positive: 1} else {negative: 1}}

    # Train data
    #
    # @param [Array] data cocolour style data [{rgbColors, score}]
    # @note this method can only be called once
    #
    train: (data) ->
        @net.train @preprocess(data), @options
        @fn = @net.toFunction()

    # Verify data
    #
    # @param [Array] data cocolour style data [{rgbColors, score}]
    #
    verify: (data) ->
        tests = data.map (scheme) =>
            rate = @rate scheme
            expectation = if scheme.score > 0 then "positive" else "negative"
            match = expectation == rate
            console.log ""
            console.log "Rate: ", rate
            console.log "Expectation: ", expectation
            console.log "Match?: ", match
            match
        passed = (tests.filter (elem) -> elem).length
        rate = passed / tests.length
        console.log ""
        console.log "Tests: ", tests.length
        console.log "Passed Tests: ", passed
        console.log "Rate(%): ", rate
        {length: tests.length, passed: passed, rate: rate}

    # Rate given scheme
    #
    # @param [Object] data cocolour style data {rgbColors, score}
    # @return [Int] {1: like, 0: normal, -1: dislike}
    #
    rate: (scheme) ->
        [{input}] = @preprocess [scheme]
        pairs = _.pairs @fn(input)
        pairs.sort (a, b) -> b[1] - a[1]
        pairs[0][0]

module.exports = ANN