activePalette = []
currentPalette = 0
paletteWasShuffled = false
pressingDown = false
pixels = []
PIXEL_SIZE = 20
CANVAS_SIZE = 400
canvasChanged = false
TRANSITION_END = 'webkitTransitionEnd otransitionend oTransitionEnd msTransitionEnd transitionend'
evaluatedDrawingState = ""

selectColor = (context) ->
  console.log 'selectColor'
  color = $(context).css('background-color')
  highlightActivePaletteColor(context)

updateFeelsHeaderColor = () ->
  color = $('.active').css('background-color')
  $('.feels').css('color', color)

highlightActivePaletteColor = (context) ->
  $('.color').removeClass('active')
  $(context).addClass('active')
  $(context).one TRANSITION_END, ->
    updateFeelsHeaderColor()

updatePalette = () ->
  for color, index in activePalette
    paletteContext = $('.palette-color')[index]
    $(paletteContext).css('background-color', color)
    if index is 0
      context = $('.palette-color')[0]
      selectColor(context)

newPalette = () ->
  totalPalettes = palettes.length - 1
  if currentPalette > totalPalettes
    currentPalette = 0
  activePalette = palettes[currentPalette]
  updatePalette()
  currentPalette = currentPalette + 1

$('.color').on 'click', ->
  console.log 'color click'
  context = @
  selectColor(context)

$(document).keypress (key) ->
  if key.which is 49
    context = $('.color')[0]
    selectColor(context)
  else if key.which is 50
    context = $('.color')[1]
    selectColor(context)
  else if key.which is 51
    context = $('.color')[2]
    selectColor(context)
  else if key.which is 52
    context = $('.color')[3]
    selectColor(context)
  else if key.which is 53
    context = $('.color')[4]
    selectColor(context)
  else if key.which is 54
    context = $('.color')[5]
    selectColor(context)
  else if key.which is 55
    $('.shuffle').trigger('click')

$('.shuffle').on 'click', ->
  console.log 'shuffle'
  paletteWasShuffled = true
  newPalette()

$('.shuffle').hover ->
  console.log this

  
# PAINTING
  
$('.pixel').on "mousedown touchstart", (event) ->
  color = $('.color.active').css('background-color')
  pressingDown = true
  $(@).css("background-color", color)
  critiqueDrawing()
  unless color is 'black'
    canvasChanged = true

$('.pixel').on "mousemove", (event) ->
  color = $('.color.active').css('background-color')
  if pressingDown
    $(event.target).css("background-color", color)
    critiqueDrawing()

$('.pixel').on "touchmove", (event) ->
  color = $('.color.active').css('background-color')
  if pressingDown
    event.preventDefault()
    myLocation = event.originalEvent.changedTouches[0]
    realTarget = document.elementFromPoint(myLocation.clientX, myLocation.clientY) or @
    console.log realTarget
    if $(realTarget).hasClass 'pixel'
      $(realTarget).css("background-color", color)
      critiqueDrawing()

$(document).mouseup (event) ->
  if pressingDown
    pressingDown = false

      
# ART CRITIQUE

drawingIsTooEmpty = ->
  EMPTY_PIXEL = "rgb(0, 0, 0)"
  PIXELS_PER_ROW= 20
  PIXELS_TOTAL = 400
  filledPixels = []
  thirdLastRowIndex = PIXELS_TOTAL - (PIXELS_PER_ROW * 3)
  lastThreeRowsPixels = _.rest(pixels, thirdLastRowIndex)
  lastThreeRowsPixels.filter (pixel) ->
    if pixel != EMPTY_PIXEL
      filledPixels.push pixel
  true unless filledPixels.length

drawingIsNotEnoughColors = ->
  EMPTY_PIXEL = "rgb(0, 0, 0)"
  coloredPixels = []
  pixels.filter (pixel) ->
    if pixel != EMPTY_PIXEL
      coloredPixels.push pixel
  true unless _.uniq(coloredPixels).length >= 3

getCritique = ->
  if drawingIsTooEmpty()
    if evaluatedDrawingState != 'drawingIsTooEmpty'
      evaluatedDrawingState = 'drawingIsTooEmpty'
      responses = [
        "Paint with passion"
        "Don’t hold back"
        "Fill our hearts with art"
        "Bare your soul to us"
      ]
      _.sample responses
  else if drawingIsNotEnoughColors()
    if evaluatedDrawingState != 'drawingIsNotEnoughColors'
      evaluatedDrawingState = 'drawingIsNotEnoughColors'
      responses = [
        "I’d love more colors"
        "Something is still missing"
        "Enlighten me with more colors"
        "The art world needs more colors"
      ]
      _.sample responses
  else if paletteWasShuffled
    if evaluatedDrawingState != 'paletteWasShuffled'
      evaluatedDrawingState = 'paletteWasShuffled'
      responses = [
        "Fresh like a morning baguette!"
        "You really know how to create real art!"
        "I’m telling everyone about your talent!"
        "A fine addition to my family heirlooms!"
        "Provoking and shocking, I love it!"
        "This touches my soul, bravo!"
        "I hope you achieve all your dreams!"
      ]
      _.sample responses
  else
    if evaluatedDrawingState != 'paletteWasNotShuffled'
      evaluatedDrawingState = 'paletteWasNotShuffled'
      responses = [
        "I want more radical colors with (/・・)ノ"
        "Summer colors (/・・)ノ will add more passion"
        "With even more colors, this will be wow (/・・)ノ"
        "Click (/・・)ノ for even more colors"
      ]
      _.sample responses


critiqueDrawing = ->
  getPixels()
  critique = getCritique()
  if critique
    element = document.getElementById('critique')
    element.innerText = critique


# SAVING

getPixels = () ->
  drawing = $('.drawing .pixel')
  pixels = []
  for pixel in drawing
    pixelColor = $(pixel).css('background-color')
    pixels.push(pixelColor)

paintCanvasRow = (pixelColor, index, row) ->
  X = PIXEL_SIZE * index - (CANVAS_SIZE * row)
  Y = PIXEL_SIZE * row
  canvas = document.getElementById("canvas")
  context = canvas.getContext '2d'
  context.fillStyle = pixelColor
  context.fillRect(X, Y, PIXEL_SIZE, PIXEL_SIZE)

drawPixelsOnCanvas = (pixels) ->
  for pixelColor, index in pixels
    if index < 20
      paintCanvasRow(pixelColor, index, 0)
    if index < 40
      paintCanvasRow(pixelColor, index, 1)
    if index < 60
      paintCanvasRow(pixelColor, index, 2)
    if index < 80
      paintCanvasRow(pixelColor, index, 3)
    if index < 100
      paintCanvasRow(pixelColor, index, 4)
    if index < 120
      paintCanvasRow(pixelColor, index, 5)
    if index < 140
      paintCanvasRow(pixelColor, index, 6)
    if index < 160
      paintCanvasRow(pixelColor, index, 7)
    if index < 180
      paintCanvasRow(pixelColor, index, 8)
    if index < 200
      paintCanvasRow(pixelColor, index, 9)
    if index < 220
      paintCanvasRow(pixelColor, index, 10)
    if index < 240
      paintCanvasRow(pixelColor, index, 11)
    if index < 260
      paintCanvasRow(pixelColor, index, 12)
    if index < 280
      paintCanvasRow(pixelColor, index, 13)
    if index < 300
      paintCanvasRow(pixelColor, index, 14)
    if index < 320
      paintCanvasRow(pixelColor, index, 15)
    if index < 340
      paintCanvasRow(pixelColor, index, 16)
    if index < 360
      paintCanvasRow(pixelColor, index, 17)
    if index < 380
      paintCanvasRow(pixelColor, index, 18)
    if index < 400
      paintCanvasRow(pixelColor, index, 19)

iterateDrawingsCount = () ->
  count = 1
  drawings = localStorage.getItem('drawingsCount')
  if drawings
    count = parseInt(drawings) + count
  localStorage.setItem('drawingsCount', count)
  
drawingSaved = () ->
  $('.save-drawing').hide()
  $('.palette').hide()
  $('.drawing').hide()
  $('#canvas').show()
  $('.drawing-saved').show()
  iterateDrawingsCount()

saveCanvas = () ->
  canvas = document.getElementById("canvas")
  drawing = canvas.toDataURL("image/png")
  feeling = $('.topic')[0].textContent
  $.post '/save-drawing', {'image': drawing, feeling: feeling}, (response) ->
    if response.code is 200
      drawingSaved()
    else
      console.error 'saveCanvas() error'
      drawingSaved()

updateDrawingsCreatedCount = ->
  count = window.localStorage.getItem 'drawingsCreated'
  if count
    newCount = parseInt(count) + 1
    window.localStorage.setItem 'drawingsCreated', newCount
  else
    window.localStorage.setItem 'drawingsCreated', 1
      
$('.save-button').on 'click touchstart', ->
  if canvasChanged
    $(this).addClass 'hidden'
    $('.saving-button').removeClass 'hidden'
    pixels = []
    getPixels()
    drawPixelsOnCanvas(pixels)
    saveCanvas()
    updateDrawingsCreatedCount()

$ ->
  newPalette()
  critiqueDrawing()
