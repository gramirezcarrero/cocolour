colorsClustering = require "colors-clustering"
$ = require "jquery"

display = (clusters) ->
  html = clusters.map (cluster) ->
    color = cluster.color
    "<div class='color' style='background: rgb(#{color.join(',')})'></div>"
  html = "<div class='colors'>#{html.join('')}</div>"
  document.getElementById("colors").innerHTML = html

body = document.body
body.ondragover = (event) -> event.preventDefault()
body.ondragend = (event) -> event.preventDefault()
body.ondragenter = (event) -> event.preventDefault()
body.ondragleave = (event) -> event.preventDefault()
body.ondrag = (event) -> event.preventDefault()
body.ondrop = (event) ->
  event.preventDefault()
  box = document.getElementById("image")
  box.style.lineHeight = 0
  document.getElementById("colors").innerHTML = "Calculating..."
  url = URL.createObjectURL(event.dataTransfer.files[0])
  config =
    src: url
    minCount: 7
  colorsClustering config, (clusters) ->
    display clusters
    clusters.sort (a, b) -> b.weight - a.weight
    colorMatchings = []
    # 列出选择排列的所有可能性
    C = (arr, n) ->
      results = []
      iter = (t, arr, n) ->
        if n is 0
          results.push t
        else
          for i in [0..(arr.length - n)]
            iter t.concat(arr[i]), arr.slice(i+1), (n - 1)
      iter [], arr, n
      results
    # schemes = C([0...clusters.length], 5).map (scheme) ->
    #   scheme.map (i) -> clusters[i].color
    # console.log schemes

    # 目前只用了前 7 种颜色进行组合
    schemes = C([0...7], 5).map (scheme) ->
      scheme.map (i) -> clusters[i].color

    html = schemes.map (colors) ->
      tmp = colors.map (color) ->
        "<div class='color' style='background: rgb(#{color.join(',')})'></div>"
      "<div class='scheme'>#{tmp.join('')}
        <i class='fa fa-heart-o button'></i>
        <i class='fa fa-trash-o button'></i></div>"
    document.getElementById("schemes").innerHTML = html.join('')
    $('.scheme .button').click ->
      $(this).toggleClass 'selected'
  img = new Image
  img.src = url
  img.onload = ->
    box.innerHTML = ""
    box.appendChild img
