jQuery ->
	$(".remote-checkbox").on("click", (event) ->
			$($(this)[0].form).trigger("submit.rails")
		)