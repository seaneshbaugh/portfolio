#= require jquery
#= require jquery_ujs
#= require_self

$(document).ready ->
  if history and history.pushState
    $("nav ul li a").click ->
      link = @href
      $("#content").slideUp 500, ->
        $.getScript link, ->
          $("#content").slideDown 500

      history.pushState null, document.title, @href
      false

    $(window).bind "popstate", ->
      $.getScript location.href
