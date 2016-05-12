$ ->
  #populate result with first job
  first_result = $('.job-button')

  comment_count = first_result.find('h1.job-title').data('comment-count')
  id = first_result.find('h1.job-title').attr('id')
  content = first_result.eq(0).data('job')
  header = first_result.eq(0).data('header')

  $('#result').append("<a href='/jobs/" + id + "/comments'>Comments(" + comment_count + ")</a><br>")
  $('#result').append("<h1 class='header'>" + header + "</h1><br>")
  $('#result').append(content)

  #apply active class to first job button when page loads
  $('.job-button').eq(0).addClass('active-job')


  #show job from data attribute when button is clicked
  $('.job-button').click () ->
    $('#result').html('')

    #append comments
    comment_count = $(this).find('h1.job-title').data('comment-count')
    id = $(this).find('h1.job-title').attr('id')
    $('#result').append("<a href='/jobs/" + id + "/comments'>Comments(" + comment_count + ")</a><br>")

    content = $(this).eq(0).data('job')
    header = $(this).eq(0).data('header')

    $('#result').append("<h1 class='header'>" + header + "</h1><br>")
    $('#result').append(content)
    
    $('.job-button').removeClass('active-job')
    $(this).addClass('active-job')
