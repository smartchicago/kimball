//All time is converted to seconds for easier comparison

$(function(){
 
  var endTimeElement = $("#v2_event_invitation_end_time");  

  $("#submit").click(function(e){

    if (isTimeWindowMultipleOfSlotLength()) {
      var warningMessage = "Your time window is not a multiple of the call length. Do you still want to save the Event?";
      if (!confirm(warningMessage))
        e.preventDefault();
      //endTimeElement.wrap("<div class='field_with_errors'>Your time window should be a multiple of the call length</div>");
    } 

  });

  function isTimeWindowMultipleOfSlotLength() {
    var slotLength = parseInt($("#v2_event_invitation_slot_length").val().substr(0,2)) * 60;
    var startTime = timeToSeconds($("#v2_event_invitation_start_time").val());
    var endTime = timeToSeconds(endTimeElement.val());

    return ((endTime - startTime) % slotLength != 0);
  }

  function timeToSeconds(time) {
    time = time.split(/:/);
    return time[0] * 3600 + time[1] * 60;
  }
});