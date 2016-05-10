$ ->
  #populate result with first job
  first_result = $('.job-button').eq(0).data('job')
  $('#result').append(first_result)

  #apply active class to first job button when page loads
  $('.job-button').eq(0).addClass('active-job')


  $('.job-button').click () ->
    $('#result').html('')
    console.log($(this))
    data = $(this).eq(0).data('job')
    console.log data
    $('#result').append(data)
    id = $(this).find('h1.job-title').attr('id')
    comment_count = $(this).find('h1.job-title').data('comment-count')
    $('#result').append("<a href='/jobs/" + id + "/comments'>Comments(" + comment_count + ")</a>")

    $('.job-button').removeClass('active-job')
    $(this).addClass('active-job')
