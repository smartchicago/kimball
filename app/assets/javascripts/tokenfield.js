$(document).on('ready page:load',function() {
  // this is used on search and on interview/event_invitation
  // can't create new tokens with this.

  // id is always numeric, but stored in string.
  // value is either the person ID or tag name, string
  // name is always a string, name of object, what is displayed
  var tokenSelector = '.tokenfield';
  if ($(tokenSelector).length) {
    var bloodhound, filter, tokenSelector, cached_suggestions;
    var searchUrl, prePopulate;

    searchUrl    = $("[data-search-url]").data().searchUrl.toString();
    prePopulate  = $("[data-pre-populate]").data().prePopulate;

    // untill we get em, we save em.
    cached_suggestions = [];


    $(tokenSelector).on('tokenfield:createtoken', function(event) {

      var existingTokens = $(this).tokenfield('getTokens');
      var should_prevent_default =  false
      var event_value = event.attrs.value.toString();
      var attrs = event.attrs
      // can't add the same tag twice
      $.each(existingTokens, function(index, token) {
        if (token.value.toString() === event_value) {
          should_prevent_default = true;
        }
        token.value = token.name;
      });

      // can't add a token not in the sugestions
      // this is a very rudimentary cache.
      if (prePopulate!=='') {
        cached_suggestions = cached_suggestions.concat();
      }
      suggestion_values = cached_suggestions.map(function(e,i) {
        return e.name.toString();
      });

      if ($.inArray(event_value,suggestion_values) === -1) {

        should_prevent_default = true;
      }
      // failed the tests above
      if(should_prevent_default === true){
        event.preventDefault();
      }
    });

    // make tokens from typeahead selections
    $(tokenSelector).on('typeahead:selected typeahead:autocomplete', function (e,datum){
      $(tokenSelector).tokenfield('createTokensFromInput');
    });


    //filter pre-existing tags from the tagfield
    var filter = function(suggestions) {
      // this is a relatively ugly caching mechanism.
      // would like something better.
      cached_suggestions = suggestions;

      var current, filtered, results;
      // using names here, not values
      current = $(tokenSelector).tokenfield('getTokens').map(function(e,i) {
        return e.name;
      });

      return $.grep(suggestions, function(suggestion) {
        return $.inArray(suggestion.name, current) === -1;
      });
    };

    // searching from the server
    var bloodhound = new Bloodhound({
      datumTokenizer: function(d) {
        return Bloodhound.tokenizers.whitespace(d.name);
      },
      queryTokenizer: Bloodhound.tokenizers.whitespace,
      remote: {
        url: searchUrl,
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

    var prepopulate_tokens = function(tokens){
      cached_suggestions = tokens;
      $.each(tokens, function(k, v) {
          v["value"] = v["name"];
      });
      $(tokenSelector).tokenfield('setTokens',tokens)
    }

    if (typeof prePopulate !== 'undefined' && prePopulate != '') {
     console.log(prePopulate);
     prepopulate_tokens(prePopulate);
    }
  } // end of check for tokenfield selector
});
