//= require seamless/build/seamless.child.min.js
$(document).ready(function() {
  $("#new_person").validate({
    rules: {
      "person[first_name]": {
        required: true
      },
      "person[last_name]": {
        required: true
      },
      "person[email_address]": {
        email: true,
        require_from_group: [1, ".contact"]
      },
      "person[phone_number]": {
        phoneUS: true,
        require_from_group: [1, ".contact"]
      },
      "person[postal_code]":{
        zipcodeUS: true,
        required: true
      }
    },
    // errorPlacement: function(error, element) {
    //   error.appendTo( $("label:first") );
    // }
   });
 });