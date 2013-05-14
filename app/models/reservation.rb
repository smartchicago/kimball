class Reservation < ActiveRecord::Base
  validates_presence_of :person_id, :event_id

  belongs_to :person
  belongs_to :event
  
  after_create  { person.update_index }
  after_destroy { person.update_index }
end
