//All time is converted to seconds for easier comparison

$(function(){

  var slotLengthElement = $("#v2_event_invitation_slot_length");
  var startTimeElement = $("#v2_event_invitation_start_time");
  var endTimeElement = $("#v2_event_invitation_end_time");

  $("#submit").click(function(e){
    var slotLength = parseInt(slotLengthElement.val().substr(0,2)) * 60;
    var startTime = timeToSeconds(startTimeElement.val());
    var endTime = timeToSeconds(endTimeElement.val());

    if(isEndTimeAfterStartTime(startTime, endTime)){
      var alertMessage = "Please make sure that the End time is greater than the Start time"
      alert(alertMessage);
      endTimeElement.wrap("<div class='field_with_errors'></div>");
      e.preventDefault();
    }

    if (isTimeWindowMultipleOfSlotLength(slotLength, startTime, endTime)) {
      var warningMessage = "Your time window is not a multiple of the call length. Do you still want to save the Event?";
      if (!confirm(warningMessage))
        e.preventDefault();
    }

  });

  function isTimeWindowMultipleOfSlotLength(slotLength, startTime, endTime) {
    return ((endTime - startTime) % slotLength != 0);
  }

  function isEndTimeAfterStartTime(startTime, endTime) {
    return !(endTime > startTime)
  }

  function timeToSeconds(time) {
    time = time.split(/:/);
    return time[0] * 3600 + time[1] * 60;
  }
  $('.datepicker').datepicker();
});