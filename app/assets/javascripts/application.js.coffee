#= require jquery
#= require jquery-ui
#= require jquery_ujs
#= require_self

$(document).ready ->
  if history and history.pushState
    $(document).on "click", ".ajax-link", (event) ->
      link = @href
      $("#content").fadeOut 500, ->
        $.getScript link, ->
          $("#content").fadeIn 500
      history.pushState null, document.title, @href
      false

    $(window).bind "popstate", ->
      $.getScript location.href

  $(".click-to-close").on "click", (event) ->
    event.preventDefault()
    $(this).fadeTo 400, 0, ->
      $(this).slideUp 400

  $("#main-nav ul li a").each ->
    if $(this).data("hover-color") isnt `undefined`
      $(this).fadingLinks($(this).data("hover-color"))

$.fn.fadingLinks = (color, duration = 500) ->
  @each ->
    original = $(this).css("color")
    $(this).mouseover ->
      $(this).stop().animate color: color, duration

    $(this).mouseout ->
      $(this).stop().animate color: original, duration
