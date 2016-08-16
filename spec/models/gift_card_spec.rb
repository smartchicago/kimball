require 'rails_helper'

RSpec.describe GiftCard, type: :model do
  # it { is_expected.to validate_presence_of(:amount) }
  it { is_expected.to validate_presence_of(:reason) }
end
