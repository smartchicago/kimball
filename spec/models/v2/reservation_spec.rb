# == Schema Information
#
# Table name: v2_reservations
#
#  id           :integer          not null, primary key
#  time_slot_id :integer
#  person_id    :integer
#

require 'rails_helper'

describe V2::Reservation do
  it { is_expected.to validate_presence_of(:person) }
  it { is_expected.to validate_presence_of(:time_slot) }
end
