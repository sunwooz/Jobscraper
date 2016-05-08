$ ->
  $('.job-button').click () ->
    $('#result').html('')
    console.log($(this))
    data = $(this)[0].dataset["job"]
    console.log data
    $('#result').append(data)
