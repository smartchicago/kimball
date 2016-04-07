$(document).on('ready page:load', function () {

  // initialize bloodhound engine
  var searchSelector = 'input#typeahead';


  //filters out tags that are already in the list
  var filter = function(suggestions) {
    var current_tags = $('#tag-list li').map(function(index,el){
      return el.children[0].text
    })
    return $.grep(suggestions, function(suggestion) {
        return $.inArray(suggestion.name,current_tags) === -1;
    });
  }

  var bloodhound = new Bloodhound({
    datumTokenizer: function (d) {
      return Bloodhound.tokenizers.whitespace(d.value);
    },
    queryTokenizer: Bloodhound.tokenizers.whitespace,

    // sends ajax request to remote url where %QUERY is user input
    remote: {
      url:'/taggings/search?q=%QUERY',
      wildcard: '%QUERY',
      limit: 20,
      filter: filter
    }
  });
  bloodhound.initialize();

  // initialize typeahead widget and hook it up to bloodhound engine
  // #typeahead is just a text input
  $(searchSelector).typeahead(null, {
    name: 'Tags',
    displayKey: 'name',
    source: bloodhound.ttAdapter()
  })

});