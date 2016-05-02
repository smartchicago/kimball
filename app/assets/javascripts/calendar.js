$(document).on('ready page:load', function () {


  // users won't have a token.
  var token_param = '';
  if (token) { token_param = "?token="+ token; }


  var event_sources = {
    reservations: {
     url: "/calendar/reservations.json" + token_param
    },
    event_slots: {
      url: '/calendar/event_slots.json' + token_param
    }
  }

  // simple mobile detection
  var isMobile = window.matchMedia("only screen and (max-width: 760px)");

  $('#calendar').fullCalendar({
    header: {
      left: 'prev,next today',
      center: 'title',
      right: 'month,agendaWeek,agendaDay'
    },
    defaultView: isMobile.matches ? 'agendaDay' : 'agendaWeek',
    defaultDate: moment( new Date().toJSON().slice(0, 10) ),
    editable: false,
    businessHours:{
      start:'9:00',
      end: '20:00'
    },
    //eventLimit: true, // allow "more" link when too many events
    eventSources: [
      event_sources['reservations'],
      event_sources['event_slots']
    ]
  })

});
