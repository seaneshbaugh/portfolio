#= require jquery
#= require jquery-ui
#= require jquery_ujs
#= require_self

$(document).ready ->
  if history and history.pushState
    $("#nav ul li a").click ->
      link = @href
      $("#content").slideUp 500, ->
        $.getScript link, ->
          $("#content").slideDown 500

      history.pushState null, document.title, @href
      false

    $(window).bind "popstate", ->
      $.getScript location.href




  #$("#main-nav ul li a").fadingLinks("#ffffff")

  return

$.fn.fadingLinks = (color, duration = 500) ->
  @each ->
    original = $(this).css("color")
    $(this).mouseover ->
      $(this).stop().animate color: color, duration

    $(this).mouseout ->
      $(this).stop().animate color: original, duration

