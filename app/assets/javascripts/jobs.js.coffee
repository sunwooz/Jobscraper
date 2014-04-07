$(document).ready ->

  scrollToElement = (selector, time, verticalOffset) ->
    time = typeof(time) != 'undefined' ? time : 1000
    verticalOffset = typeof(verticalOffset) != 'undefined' ? verticalOffset : 0
    element = $(selector)
    offset = element.offset()
    offsetTop = offset.top + verticalOffset
    $('html, body').animate({
        scrollTop: offsetTop
    }, time)

  # $('h3').click ->
  #   scrollToElement(this)
