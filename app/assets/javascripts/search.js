$(document).on('ready page:load', function() {
  // this is for tags!
  var bloodhound, filter, searchSelector;

  $("#export-to-twilio-form-toggle").click(function() {
    $("#export-to-twilio-form").toggle();
    return false;
  });

  $("#export-to-mailchimp-form-toggle").click(function() {
    $("#export-to-mailchimp-form").toggle();
    return false;
  });

  searchSelector = '.tokenfield';

  // preventing enter from submitting form
  $(searchSelector).keydown(function(event){
    if(event.keyCode === 13) {
      event.preventDefault();
      return true;
    }
  });

  //can't add the same tag twice
  $(searchSelector).on('tokenfield:createtoken', function(event) {
    var existingTokens;
    existingTokens = $(this).tokenfield('getTokens');
    $.each(existingTokens, function(index, token) {
      if (token.value === event.attrs.value) {
        event.preventDefault();
      }
    });
  });

  //filter pre-existing tags from the tagfield
  filter = function(suggestions) {
    var current, filtered, results;
    current = $(searchSelector).tokenfield('getTokens').map(function(e,i) {
      return e.name;
    });
    return $.grep(suggestions, function(suggestion) {
      console.log(suggestion.name);
      return $.inArray(suggestion.name, current) === -1;
    });
  };

  $(searchSelector).on('typeahead:selected', function (){
    $(searchSelector).tokenfield('createTokensFromInput');
  });

  // searching from the server
  bloodhound = new Bloodhound({
    datumTokenizer: function(d) {
      return Bloodhound.tokenizers.whitespace(d.value);
    },
    queryTokenizer: Bloodhound.tokenizers.whitespace,
    remote: {
      url: '/taggings/search?q=%QUERY',
      wildcard: '%QUERY',
      limit: 20,
      filter: filter,
      cache: false
    }
  });

  bloodhound.initialize();

  //tokenfield. Might be better than typeahead
  $(searchSelector).tokenfield({
    typeahead: [
      null, {
        source: bloodhound.ttAdapter(),
        display: 'name',
        displayKey: 'name',
        showAutocompleteOnFocus: true
      }
    ]
  });
});