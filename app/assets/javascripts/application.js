//= require jquery
//= require jquery-ui
//= require jquery_ujs
//= require twitter/bootstrap
//= require vendor_assets
//= require shared
//= require_self

$.fn.fadingLinks = function(color, duration) {
    if (duration == null) {
        duration = 500;
    }

    return this.each(function() {
        var original;

        original = $(this).css("color");

        $(this).mouseover(function() {
            return $(this).stop().animate({
                color: color
            }, duration);
        });

        return $(this).mouseout(function() {
            return $(this).stop().animate({
                color: original
            }, duration);
        });
    });
};

$(function() {
    $("a").each(function() {
        if ($(this).data("hover-color") !== undefined) {
            $(this).fadingLinks($(this).data("hover-color"));
        } else {
            $(this).fadingLinks("#005580");
        }
    });
});