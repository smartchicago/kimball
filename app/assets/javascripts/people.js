$(document).on('ready page:load', function () {

  // initialize bloodhound engine
  var searchSelector = 'input#tag-typeahead';


  //filters out tags that are already in the list
  var filter = function(suggestions) {
    var current_tags = $('#tag-list li').map(function(index,el){
      return el.children[0].text;
    });
    return $.grep(suggestions, function(suggestion) {
        return $.inArray(suggestion.name,current_tags) === -1;
    });
  };

  var bloodhound = new Bloodhound({
    datumTokenizer: function (d) {
      return Bloodhound.tokenizers.whitespace(d.value);
    },
    queryTokenizer: Bloodhound.tokenizers.whitespace,
    remote: {
      url:'/taggings/search?q=%QUERY',
      wildcard: '%QUERY',
      limit: 20,
      filter: filter,
      cache: false
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

  //submits the tag once selected from the typeahead
  $(searchSelector).on('typeahead:selected', function(obj, datum){ //datum
    $(searchSelector).typeahead('val',datum.name);
    $('#tag-typeahead').submit();
  });
  $("#gift_card_expiration_date").mask("99/99",{placeholder:"MM/YY"});
  $('#new-notes').hide();
    
  $('#new-reason').change(function () {
    console.log("new-reason change");
    if ($('#new-reason option:selected').text() == "Other"){
      console.log("new-reason other");
      $('#new-notes').show();
    } else {
      $('#new-notes').hide();
    }
  }); 
});
