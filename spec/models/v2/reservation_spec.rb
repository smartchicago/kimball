require 'rails_helper'

describe V2::Reservation do
  it { is_expected.to validate_presence_of(:person) }
  it { is_expected.to validate_presence_of(:time_slot) }
end
