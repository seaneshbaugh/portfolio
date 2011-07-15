$(document).ready(function(){
	$(".check-all").click(
		function(){
			$(this).parent().parent().parent().parent().find("input[type='checkbox']").attr("checked", $(this).is(":checked"));
		}
	);

	$("input:checkbox").click(
		function(){
			var buttonsChecked = $("input:checkbox:checked");

			if (buttonsChecked.length) {
				$("#edit-selected-button").removeAttr("disabled");
				$("#delete-selected-button").removeAttr("disabled");
			} else {
				$("#edit-selected-button").attr("disabled", "disabled");
				$("#delete-selected-button").attr("disabled", "disabled");
			}
		}
	);
});
