$('.new-election form').submit ->
  $('input').removeClass('error')
  question = $('#question').val()
  award = $('#award').val()
  $('.validating-button, .submit').toggleClass 'hidden'

  $.post "/new-election", 
    question: question
    award: award
  .always (response) ->
    console.log response
    if response
      $('.new-election, .new-election-success').toggleClass 'hidden'
      addElection response
    else
      $('.validating-button, .submit').toggleClass 'hidden'
      $('input').addClass('error')
  return false

addElection = (response) ->
  table = document.getElementById 'elections-table'
  newRow = table.insertRow(table.rows.length)

  awardCell = newRow.insertCell(0)
  awardCell.innerHTML = response.award

  questionCell = newRow.insertCell(0)
  questionCell.innerHTML = response.question

  weekCell  = newRow.insertCell(0)
  weekCell.innerHTML = response.week
