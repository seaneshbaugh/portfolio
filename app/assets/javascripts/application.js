//= require jquery
//= require jquery_ujs
//= require twitter/bootstrap
//= require vendor_assets
//= require shared
//= require_self

$.fn.fadingLinks = function(color, duration) {
    if (!duration) {
        duration = 500;
    }

    return this.each(function() {
        var link, original;

        link = $(this);

        original = link.css("color");

        link.mouseover(function() {
            return link.stop().animate({
                color: color
            }, duration);
        });

        return link.mouseout(function() {
            return link.stop().animate({
                color: original
            }, duration);
        });
    });
};

$(function() {
    $("a").each(function() {
        var link;

        link = $(this);

        if (link.data("hover-color")) {
            link.fadingLinks(link.data("hover-color"));
        } else {
            link.fadingLinks("#005580");
        }
    });
});
