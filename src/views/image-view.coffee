colorsClustering = require "colors-clustering"
GenePool = require 'gene-pool'
fitness = require '../fitness.coffee'
$ = require 'jquery'

SchemesView = require('./schemes-view.coffee')

parseImage = (url) ->
    config =
        src: url
        minCount: 7

    displayColors = (clusters) ->
        html = clusters.map (cluster) ->
            color = cluster.color
            "<div class='color' style='background: rgb(#{color.join(',')})'></div>"
        html = "<div class='colors'>#{html.join('')}</div>"
        $("#colors").html html

    colorsClustering config, (clusters) ->
        clusters.sort (a, b) -> b.weight - a.weight
        displayColors clusters
        opts =
            genes: clusters.map (color) -> color.color
            weights: clusters.map (color) -> color.weight
            K: 20
            N: 5
            mutationRate: 0.2
            birthRate: 1
            fitness: fitness
        colorSchemes = new GenePool(opts)
        colorSchemes.timeout 800, (err, schemes) ->
            console.error(err) if err
            new SchemesView(schemes)
    $('#image').css {backgroundImage: "url(#{url})"}

class ImageView
    constructor: (url = './static/images/default.jpg') ->
        # show #image
        $('#image').show()

        # parse & show schemes
        parseImage url

        # bind DND events
        target = $('#image')[0]
        target.ondragover = (event) -> event.preventDefault()
        target.ondragend = (event) -> event.preventDefault()
        target.ondragenter = (event) -> event.preventDefault()
        target.ondragleave = (event) -> event.preventDefault()
        target.ondrag = (event) -> event.preventDefault()
        target.ondrop = (event) ->
            event.preventDefault()
            url = URL.createObjectURL(event.dataTransfer.files[0])
            parseImage url
        $('#load-image').on 'click', ->
            $input = $('<input type="file">')
            $('body').append $input
            $input.on 'change', (e) ->
                files = $input[0].files
                if files
                    url = URL.createObjectURL(files[0])
                    parseImage url
                    $input.remove()
            $input.click()

module.exports = ImageView
