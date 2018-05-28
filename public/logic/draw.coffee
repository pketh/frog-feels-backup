activePalette = []
currentPaletteIndex = 0
paletteWasUpdated = false
pressingDown = false
currentStroke = []
strokeUndoHistory = []
strokeRedoHistory = []
canvasChanged = false
TRANSITION_END = 'webkitTransitionEnd otransitionend oTransitionEnd msTransitionEnd transitionend'
evaluatedDrawingState = ""

# from https://stackoverflow.com/questions/9923890/removing-duplicate-objects-with-underscore-for-javascript
_.mixin
  deepUniq: (coll) ->
    result = []
    remove_first_el_duplicates = (coll2) ->
      rest = _.rest(coll2)
      first = _.first(coll2)
      result.push first
      equalsFirst = (el) -> _.isEqual(el,first)
      newColl = _.reject rest, equalsFirst
      unless _.isEmpty newColl
        remove_first_el_duplicates newColl
    remove_first_el_duplicates(coll)
    result

setPixelHeight = ->
  pixels = document.querySelectorAll('.pixel')
  width = pixels[0].offsetWidth
  for pixel in pixels
    pixel.style.height = width - 1
    

# PALETTES
    
selectColor = (context) ->
  color = $(context).css('background-color')
  highlightActivePaletteColor(context)

currentColor = () -> 
  $('.color.active').css('background-color')
  
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
  currentPaletteIndex = nextPaletteIndex()
  nextPalettePreviewColors()

newPalette = () ->
  totalPalettes = palettes.length - 1
  if currentPaletteIndex > totalPalettes
    currentPaletteIndex = 0
  activePalette = palettes[currentPaletteIndex]
  updatePalette()
  
$('.color').on 'click', ->
  console.log 'color click'
  context = @
  selectColor(context)

$(document).keypress (event) ->
  redoKeys = (event.metaKey and event.shiftKey and event.key is 'z') or (event.ctrlKey and event.key is 'y')
  undoKeys = (event.metaKey and event.key is 'z') or (event.ctrlKey and event.key is 'z')
  if event.key is "1"
    context = $('.color')[0]
    selectColor(context)
  else if event.key is "2"
    context = $('.color')[1]
    selectColor(context)
  else if event.key is "3"
    context = $('.color')[2]
    selectColor(context)
  else if event.key is "4"
    context = $('.color')[3]
    selectColor(context)
  else if event.key is "5"
    context = $('.color')[4]
    selectColor(context)
  else if event.key is "6"
    context = $('.color')[5]
    selectColor(context)
  else if event.key is "7"
    $('.next-palette').trigger('click')
  else if redoKeys
    event.preventDefault()
    redoStroke()
  else if undoKeys
    event.preventDefault()
    undoStroke()

nextPaletteIndex = () ->
  totalPalettes = palettes.length - 1
  if (currentPaletteIndex + 1) > totalPalettes
    0
  else 
    currentPaletteIndex + 1

nextPalette = () ->
  activePalette = palettes[nextPaletteIndex()]
  updatePalette()

nextPalettePreviewColors = () ->
  colors = palettes[nextPaletteIndex()].slice(0,3)
  for color, index in colors
    $($('.next-palette-color')[index]).css("color", color)

  
$('.next-palette').on 'click', ->
  paletteWasUpdated = true
  nextPalette()


# PAINTING

createPixel = (target) ->
  pixelItem =
    x: target.dataset.x
    y: target.dataset.y
    color: currentColor()
  currentStroke.push pixelItem
  return pixelItem

paintPixel = (pixel) ->
  element = document.querySelectorAll("[data-x='#{pixel.x}'][data-y='#{pixel.y}']")
  $(element).css("background-color", pixel.color)

$('.pixel').on "mousedown touchstart", (event) ->
  currentStroke = []
  strokeRedoHistory = []
  pressingDown = true
  pixel = createPixel(event.target)
  paintPixel pixel
  critiqueDrawing()
  unless currentColor() is 'black'
    canvasChanged = true

$('.pixel').on "mousemove", (event) ->
  if pressingDown
    pixel = createPixel(event.target)
    paintPixel pixel
    critiqueDrawing()

$('.pixel').on "touchmove", (event) ->
  if pressingDown
    event.preventDefault()
    myLocation = event.originalEvent.changedTouches[0]
    realTarget = document.elementFromPoint(myLocation.clientX, myLocation.clientY) or @
    console.log realTarget
    if $(realTarget).hasClass 'pixel'
      pixel = createPixel(realTarget)
      paintPixel pixel
      critiqueDrawing()

$(document).mouseup (event) ->
  if pressingDown
    pressingDown = false
    stroke = _.deepUniq currentStroke
    strokeUndoHistory.push stroke


# HISTORY

clearDrawing = () ->
  drawing = $('.drawing .pixel')
  for pixel in drawing
    pixel.removeAttribute "style"
 

undoStroke = () ->
  if strokeUndoHistory.length
    strokeRedoHistory.push strokeUndoHistory.pop()
    clearDrawing()
    for stroke in strokeUndoHistory
      for pixel in stroke
        paintPixel pixel

redoStroke = () ->
  if strokeRedoHistory.length  
    currentRedo = strokeRedoHistory.pop()
    strokeUndoHistory.push currentRedo
    for pixel in currentRedo
      paintPixel pixel
    
    
# ART CRITIQUE

drawingIsTooEmpty = ->
  pixels = _.flatten(strokeUndoHistory)
  bottomPixels = pixels.filter (pixel) ->
    pixel.y > 15 and pixel.color != "rgb(0, 0, 0)"
  true unless bottomPixels.length

drawingIsNotEnoughColors = ->
  pixels = _.flatten(strokeUndoHistory)
  colorsUsed = []
  for pixel in pixels
    colorsUsed.push pixel.color
  true unless _.uniq(colorsUsed).length >= 3

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
  else if paletteWasUpdated
    if evaluatedDrawingState != 'paletteWasUpdated'
      evaluatedDrawingState = 'paletteWasUpdated'
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
        "I want more radical colors"
        "Summer colors will add more passion"
        "With even more colors, this will be wow"
        "Color my world"
      ]
      _.sample responses

critiqueDrawing = ->
  critique = getCritique()
  if critique
    element = document.getElementById('critique')
    element.innerText = critique


# SAVING

paintCanvas = () ->
  PIXEL_SIZE = 20
  canvas = document.getElementById("canvas")
  context = canvas.getContext '2d'
  for stroke in strokeUndoHistory
    for pixel in stroke
      x = (pixel.x - 1) * PIXEL_SIZE
      y = (pixel.y - 1) * PIXEL_SIZE
      context.fillStyle = pixel.color
      context.fillRect(x, y, PIXEL_SIZE, PIXEL_SIZE)
  
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
  $('#drawing-result').removeClass('hidden')
  $('.drawing-saved').show()
  iterateDrawingsCount()

pxon = ->
  feeling = $('.topic')[0].textContent
  pxon =
    exif:
      software: 'http://frogfeels.com'
      artist: 'you'
      imageDescription: feeling
      copyright: '🌎'
      dateTime: new Date()
    pxif:
      pixels: _.flatten(strokeUndoHistory) 
  console.log JSON.stringify pxon, null, '\t'
  return pxon

saveCanvas = () ->
  canvas = document.getElementById("canvas")
  drawing = canvas.toDataURL("image/png")
  feeling = $('.topic')[0].textContent
  pxon = pxon()
  result = document.getElementById("drawing-result")
  result.src = drawing
  $.post '/save-drawing', {'image': drawing, feeling: feeling, pxon: pxon}
  drawingSaved()

updateDrawingsCreatedCount = ->
  count = window.localStorage.getItem 'drawingsCreated'
  if count
    newCount = parseInt(count) + 1
    window.localStorage.setItem 'drawingsCreated', newCount
  else
    window.localStorage.setItem 'drawingsCreated', 1
  console.log "🖼 #{window.localStorage.drawingsCreated} masterpieces created"

$('.save-button').on 'click touchstart', ->
  if canvasChanged
    $(this).addClass 'hidden'
    $('.saving-button').removeClass 'hidden'
    # create gif from canvas frames
    paintCanvas()
    saveCanvas()
    updateDrawingsCreatedCount()

window.addEventListener 'load', ->
  setPixelHeight()
  newPalette()
  critiqueDrawing()

window.addEventListener 'resize', ->
  setPixelHeight()
