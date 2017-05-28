$('.sign-up form').submit ->
  console.log 'signing up', this
  input = $(this).find('input')
  console.log input
  input.removeClass('error')
  email = input.val()
  $('.validating-button, .submit').toggleClass 'hidden'
  $.post "/sign-up", {email: email}
    .always (response) ->
      console.log email
      console.log response
      if response
        $('.sign-up, .sign-up-success').toggleClass 'hidden'
      else
        $('.validating-button, .submit').toggleClass 'hidden'
        input.addClass('error')
  return false

if window.localStorage.getItem 'drawingsCreated'
  $('.sign-up form').addClass 'hidden'
