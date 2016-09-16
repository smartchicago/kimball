$(document).on('ready page:load', function() {

  $("#export-to-twilio-form-toggle").click(function() {
    $("#export-to-twilio-form").toggle();
    return false;
  });

  $("#export-to-mailchimp-form-toggle").click(function() {
    $("#export-to-mailchimp-form").toggle();
    return false;
  });

  // validating our search fields
  $("#search-form").validate({
    rules: {
      "email_address": {
        email: true
      },
      "phone_number": {
        digits: true,
        maxlength: 11,
        minlength: 11
      },
      "postal_code":{
        zipcodeUS: true
      }
    }
  });

});
