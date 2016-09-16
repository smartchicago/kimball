# == Schema Information
#
# Table name: reservations
#
#  id           :integer          not null, primary key
#  person_id    :integer
#  event_id     :integer
#  confirmed_at :datetime
#  created_by   :integer
#  attended_at  :datetime
#  created_at   :datetime
#  updated_at   :datetime
#  updated_by   :integer
#

class Reservation < ActiveRecord::Base
  has_paper_trail
  validates_presence_of :person_id, :event_id

  belongs_to :person
  belongs_to :event

  after_create  { person.update_index }
  after_destroy { person.update_index }

end
