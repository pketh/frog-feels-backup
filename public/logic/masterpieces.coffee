animationEnd = 'webkitAnimationEnd oanimationend msAnimationEnd animationend'

masterpieceBackground = ""

setMasterpieceBackground = (event) ->
  $('html').css('background-image', "url(#{masterpieceBackground})")
  $('html').css('background-attachment', "fixed")
  $(event.target).addClass 'animate-squash'

removeMasterpieceBackground = (event) ->
  $('html').css('background-image', 'none')
  masterpieceBackground = ""
  if $(event.target).hasClass 'drawing'
    $(event.target).addClass 'animate-squish'

$('.masterpieces').click (event) ->
  if $(event.target).hasClass 'drawing'
    if event.target.src != masterpieceBackground
      masterpieceBackground = event.target.src
      setMasterpieceBackground event
    else
      removeMasterpieceBackground event
  else
    removeMasterpieceBackground event

$('.masterpiece .drawing').on animationEnd, ->
  $(this).removeClass 'animate-squash'
  $(this).removeClass 'animate-squish'
