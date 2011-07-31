$(document).ready(function() {
	if (history && history.pushState) {
		$("nav ul li a").click(function() {
			var link = this.href;

			$("#content").fadeOut(500, function() {
				$.getScript(link, function() {
					$("#content").fadeIn(500);
				});
			});

			history.pushState(null, document.title, this.href);

			return false;
		});

		$(window).bind("popstate", function() {
			$.getScript(location.href);
		});
	}
});


/*$(function() {
	$("nav ul li a").click(function() {
		loadPage($(this).attr("href"));
	});
});

function loadPage(pageURI) {
	var content = $("#content");

	content.fadeOut(100, function() {
		content.load(pageURI, function() {
			content.fadeIn();
		});
	});

	return false;
}*/
