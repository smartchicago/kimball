require 'rails_helper'

describe V2::Event do
  it { is_expected.to validate_presence_of(:description) }
  it { is_expected.to validate_presence_of(:time_slots) }
end
