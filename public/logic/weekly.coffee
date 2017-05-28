$('.make-masterpiece').not(".is-masterpiece").click (event) ->
  button = $(event.target).closest('button')[0]
  data = $(button).data()
  $.post '/make-masterpiece', data, (response) ->
    button.innerHTML = 'Setting...'
  .always (response) ->
    console.log response
    button.innerHTML = "Masterpiece set"
    $(button).addClass "is-masterpiece"

$('.remove-drawing').click (event) ->
  button = $(event.target).closest('button')[0]
  data = $(button).data()
  $.post '/remove-drawing', data, (response) ->
    button.innerHTML = 'Rejecting...'
    node = $(event.target).closest('.drawing')
    console.log node
  .always (response) ->
    console.log response
    node.remove()

$('.send-weekly-email').click (event) ->
  button = $(event.target).closest('button')[0]
  data = 
    subject: $('.subject')[0].value
    intro: $('.intro')[0].value
    secret: $(button).data().secret
  console.log data
  # posts secret from env
  $.post '/send-weekly-email', data, (response) ->
    button.innerHTML = 'Sending...'
    if response.code is 200
      $('.send-weekly-email').addClass 'hidden'
      $('.email-success-message').removeClass 'hidden'
    else
      console.log 'error'

# todo: remove user on x click by posting to /unsubscribe. remove node on click.
