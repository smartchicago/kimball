// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.

// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require jquery_ujs
//= require best_in_place
//= require twitter/bootstrap
//= require twitter/typeahead.min
//= require turbolinks
//= require holder
//= require datepicker/bootstrap-datepicker.min
//= require tokenfield/bootstrap-tokenfield.js
//= require jquery.validate
//= require jquery.validate.additional-methods
//= require moment/moment.min
//= require fullcalendar/fullcalendar.min
//= require_tree .

$(document).on('ready page:load',function() {
  /* Activating Best In Place */
  jQuery(".best_in_place").best_in_place();


  var show_ajax_message = function(msg, type) {
    var cssClass = type === 'error' ? 'alert-error' : 'alert-success'
    var html ='<div class="alert ' + cssClass + '">';
    html +='<button type="button" class="close" data-dismiss="alert">&times;</button>';
    html += msg +'</div>';
    //fade_flash();
    $("#notifications").html(html);
  };

  $(document).ajaxComplete(function(event, request) {
    var msg = request.getResponseHeader('X-Message');
    var type = request.getResponseHeader('X-Message-Type');

    if (type !== null) {
      show_ajax_message(msg, type);
    }
  });

  // this is used on search and on interview/event_invitation
  // can't create new tokens with this.
  var tokenSelector = '.tokenfield';
  var bloodhound, filter, tokenSelector, cached_suggestions;

  // untill we get em, we save em.
  cached_suggestions = [];

  $(tokenSelector).on('tokenfield:createtoken', function(event) {
    var existingTokens = $(this).tokenfield('getTokens');
    var should_prevent_default =  false

    // can't add the same tag twice
    $.each(existingTokens, function(index, token) {
      if (token.value === event.attrs.value) {
        should_prevent_default = true;
      }
    });

    // can't add a token not in the sugestions
    // this is a very rudimentary cache.
    suggestion_values = cached_suggestions.map(function(e,i) {
      return e.value;
    });

    if ($.inArray(event.attrs.value,suggestion_values) === -1) {
      should_prevent_default = true;
    }
    // failed the tests above
    if(should_prevent_default === true){ event.preventDefault(); }
  });

  $(tokenSelector).on('typeahead:selected', function (){
    $(tokenSelector).tokenfield('createTokensFromInput');
  });

  //filter pre-existing tags from the tagfield
  var filter = function(suggestions) {
    // this is a relatively ugly caching mechanism.
    // would like something better.
    cached_suggestions = suggestions;
    var current, filtered, results;
    current = $(tokenSelector).tokenfield('getTokens').map(function(e,i) {
      return e.name;
    });

    return $.grep(suggestions, function(suggestion) {
      return $.inArray(suggestion.value, current) === -1;
    });
  };

  // searching from the server
  var bloodhound = new Bloodhound({
    datumTokenizer: function(d) {
      return Bloodhound.tokenizers.whitespace(d.name);
    },
    queryTokenizer: Bloodhound.tokenizers.whitespace,
    remote: {
      url: $("[data-search-url]").data()['searchUrl'],
      wildcard: '%QUERY',
      limit: 20,
      filter: filter,
      cache: false
    }
  });

  bloodhound.initialize();

  // preventing enter from submitting form
  $(tokenSelector).keydown(function(event){
    if(event.keyCode === 13) {
      event.preventDefault();
      return true;
    }
  });

  //tokenfield. Might be better than typeahead
  $(tokenSelector).tokenfield({
    typeahead: [
      null, {
        source: bloodhound.ttAdapter(),
        display: 'name',
        displayKey: 'name',
        showAutocompleteOnFocus: true
      }
    ]
  })
  // a little style. delayed, because reasons. that's why.
  $('.tokenfield').delay( 800 ).css('border','1px solid #cccccc');
  $('.tokenfield').delay( 800 ).css('border-radius','5px');


});
