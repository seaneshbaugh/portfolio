$(function() {
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
}