class Reservation < ActiveRecord::Base
  validates_presence_of :person_id, :event_id

  belongs_to :person
  belongs_to :event
end
