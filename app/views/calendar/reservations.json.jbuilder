json.array!(@reservations) do |res|
  json.extract! res, :id, :description, :title
  json.status         res.human_state
  json.start          res.start_datetime
  json.end            res.end_datetime
  json.color          'red'
  json.modal_url      calendar_show_reservation_path(id: res.id, token: @visitor.token)
  json.type           res.class.to_s.demodulize
  # json.url            event_url(event, format: :html)
end
