$('.unsubscribe form').submit ->
  input = $('.unsubscribe input')
  input.removeClass 'error'
  email = input.val()
  $('.unsubscribe, .submit').toggleClass 'hidden'
  $.post "/unsubscribe", {email: email}
    .always (response) ->
      if response
        $('.unsubscribe, .unsubscribe-success').toggleClass 'hidden'
      else
        input.addClass 'error'
  return false
