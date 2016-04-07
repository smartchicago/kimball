$(document).on('ready page:load', function () {

  // initialize bloodhound engine
  var searchSelector = 'input#typeahead';

  var bloodhound = new Bloodhound({
    datumTokenizer: function (d) {
      return Bloodhound.tokenizers.whitespace(d.value);
    },
    queryTokenizer: Bloodhound.tokenizers.whitespace,

    // sends ajax request to remote url where %QUERY is user input
    remote: {
      url:'/taggings/search?q=%QUERY',
      wildcard: '%QUERY',
      limit: 10
    }
  });
  bloodhound.initialize();

  // initialize typeahead widget and hook it up to bloodhound engine
  // #typeahead is just a text input
  $(searchSelector).typeahead(null, {
    name: 'Tags',
    displayKey: 'name',
    source: bloodhound.ttAdapter()
  });

});