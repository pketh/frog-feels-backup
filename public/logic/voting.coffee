$('.candidate').not(".voted, .unvoted").click (event) ->
  $(event.target).addClass 'voted'
  $('.candidate').not('.voted').addClass 'unvoted'
  $('.vote-saved').removeClass 'hidden'
  $.post "/add-vote", {path: event.target.dataset.path}
    .always (response) ->
      console.log response
