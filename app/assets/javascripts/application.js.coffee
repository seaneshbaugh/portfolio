#= require jquery
#= require jquery.turbolinks
#= require jquery_ujs
#= require twitter/bootstrap
#= require_self
#= require turbolinks

# $.fn.fadingLinks = (color, duration) ->
#   if !duration
#     duration = 500
#
#   @each ->
#     link = $(this)
#
#     original = link.css('color')
#
#     link.mouseover ->
#       link.stop().animate { color: color }, duration
#     link.mouseout ->
#       link.stop().animate { color: original }, duration
#
# $ ->
#   $("a").each ->
#     link = undefined
#
#     link = $(this)
#
#     if link.data("hover-color")
#       link.fadingLinks link.data("hover-color")
#     else
#       link.fadingLinks "#005580"
