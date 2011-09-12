$(document).ready(function() {
	if (history && history.pushState) {
		$("nav ul li a").click(function() {
			var link = this.href;

			$("#content").slideUp(500, function() {
				$.getScript(link, function() {
					$("#content").slideDown(500);
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
