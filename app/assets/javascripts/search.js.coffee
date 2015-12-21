# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

jQuery ->
	$("#export-to-mailchimp-form-toggle").click ->
		$("#export-to-mailchimp-form").toggle()
		return false

jQuery ->
    $("#export-to-twilio-form-toggle").click ->
		$("#export-to-twilio-form").toggle()
		return false