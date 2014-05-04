window.math = new mathjs

window.display = (colors) ->
  html = colors.map (color) ->
    unless color?
      color = [0, 0, 100]
    [h, s, l] = color
    "<div class='color' style='background: hsl(#{h}, #{s}%, #{l}%)'></div>"
  html = "<div class='colors'><h2>Clusters</h2>#{html.join('')}</div>"
  document.getElementById("colors").innerHTML += html

url = "test2.jpg"
img = new Image()
img.onload = ->

  image = this

  # todo calc scale based on w and h
  maxWidth = 100 # todo: config
  maxHeight = 100 # todo: config
  scale = Math.max (image.width / maxWidth), (image.height / maxHeight), 1

  [w, h] = [image.width, image.height].map (elem) -> parseInt (elem / scale)

  canvas = document.createElement("canvas");
  canvas.width = w
  canvas.height = h
  ctx = canvas.getContext "2d"
  ctx.drawImage this, 0, 0, image.width, image.height, 0, 0, w, h

  document.body.appendChild canvas

  imgData = ctx.getImageData(0, 0, w, h)
  points = []
  i = 0
  while( i < imgData.data.length )
    [r, g, b] = [imgData.data[i], imgData.data[i+1], imgData.data[i+2]]
    points.push window.rgb2hsl(r, g, b)
    i += 4
  console.log points.length
  centers = window.clustering(points)

img.src = url
