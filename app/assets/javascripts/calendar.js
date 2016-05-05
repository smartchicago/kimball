$(document).on('ready page:load', function () {


  // users won't have a token.
  var token_param = '';
  if (typeof(token) != "undefined") { token_param = "?token="+ token; }

  var event_sources = {
    reservations: {
      url: "/calendar/reservations.json" + token_param,
      lazyFetching: false,
      displayed: false
    },
    event_slots: {
      url: '/calendar/event_slots.json' + token_param,
      lazyFetching: false,
      displayed: false
    }
  }

  var toggle_event_source = function(event_type){
    source = event_sources[event_type]
    $('.fc-' + event_type + '-button').toggleClass('fc-state-active');
    $('#calendar').fullCalendar('removeEventSource',source);
    if (!source['displayed']) {
      $('#calendar').fullCalendar('addEventSource',source);
      source['displayed'] = true;

    }else{
      source['displayed'] = false;
    }
  }

  // simple mobile detection
  var isMobile = window.matchMedia("only screen and (max-width: 760px)");

  $('#calendar').fullCalendar({
    customButtons: {
        event_slots: {
            text: 'invitations',
            click: function() {
              toggle_event_source('event_slots');

            }
        },
        reservations: {
            text: 'reservations',
            click: function() {
                toggle_event_source('reservations');
            }
        }
    },
    header: {
      left: 'prev,next today',
      center: 'title event_slots,reservations',
      right: 'month,agendaWeek,agendaDay'
    },
    eventClick:  function(event, jsEvent, view) {
      if (event.type === 'TimeSlot') {
        $('#modalTitle').html(event.title);
        $('#modalBody').html(event.description);
        $('#modalTime').html(event.time_and_date);
        $('#eventUrl').attr('href',event.url);
        $('#v2_reservation_person_id').val(event.person_id);
        $('#v2_reservation_user_id').val(event.user_id);
        $('#v2_reservation_event_id').val(event.event_id);
        $('#v2_reservation_event_invitation_id').val(event.event_invitation_id);
        $('#v2_reservation_time_slot_id').val(event.time_slot_id);
        $('#invitationModal').modal();
      } else if (event.type === 'Reservation'){
        $('#resTitle').html(event.title);
        $('#resBody').html(event.description);
        $('#resTime').html(event.time_and_date);
        $('#reservationModal').modal();
      }


    },
    eventRender: function(event, element){
      if(event.source.rendering == 'background'){
        element.append(event.title);
      }
    },
    defaultView: isMobile.matches ? 'agendaDay' : 'agendaWeek',
    defaultDate: moment( new Date().toJSON().slice(0, 10) ),
    //eventLimit: true, // allow "more" link when too many events
    editable: false,
    businessHours:{
      start:'9:00',
      end: '20:00'
    },
    eventSources: [],

    slotDuration:'00:10:00',
    scrollTime: '09:00:00',
    minTime:'07:00:00',
    maxTime:'21:00:00',
    weekends: false
  });

  if ($('#calendar').length) { // rails?
    toggle_event_source('reservations');
    if (token !== 'false') { toggle_event_source('event_slots'); }
  }

  $('#submitButton').on('click', function(e){
    // We don't want this to act as a link so cancel the link action
    e.preventDefault();
    doSubmit();
  });

  function doSubmit(){
    $.post('/v2/reservations', $('#new_v2_reservation').serialize());
    $("#calendar").fullCalendar( 'refetchEvents' );
    $("#calendarModal").modal('hide');
  }

});
