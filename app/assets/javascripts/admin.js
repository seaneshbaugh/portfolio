//= require jquery
//= require jquery_ujs
//= require_self

$(document).ready(function(){
    $(".click-to-close").click(function() {
		$(this).fadeTo(400, 0, function () {
			$(this).slideUp(400);
		});
		return false;
	});

	if ($("#search").length) {
		if ($("#search").val().length > 0) {
			$("#search").focus();
		}
	}

	if (history && history.pushState) {
		$("#index-search").submit(function() {
			$.get(this.action, $(this).serialize(), null, "script");

			history.pushState(null, document.title, this.action + "?" + $(this).serialize());

			return false;
		});

		$("th a, .pagination a").live("click", function() {
			$.getScript(this.href);

			history.pushState(null, "", this.href);

			return false;
		});

		$(window).bind("popstate", function() {
			$.getScript(location.href);
		});
	}

	$(".check-all").click(function() {
		$(this).parent().parent().parent().parent().find("input[type='checkbox']").attr("checked", $(this).is(":checked"));
	});

	$("input:checkbox").click(function() {
		var buttonsChecked = $("input:checkbox:checked");

		if (buttonsChecked.length) {
			$("#edit-selected-button").removeAttr("disabled");
			$("#delete-selected-button").removeAttr("disabled");
		} else {
			$("#edit-selected-button").attr("disabled", "disabled");
			$("#delete-selected-button").attr("disabled", "disabled");
		}
	});

	$("#toggle-debug").click(function() {
		$("#debug-info").slideToggle();

		$(".toggle-debug-text").toggle();
	});
});
