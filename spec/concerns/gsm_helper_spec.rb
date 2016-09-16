require 'rails_helper'

describe GsmHelper do
  let(:test_class) {
    f = Struct.new(:foo) { include GsmHelper }
    f.new
  }

  it 'replaces illegal characters' do
    expect(test_class.to_gsm0338('“')).to eq('"')
    expect(test_class.to_gsm0338('”')).to eq('"')
    expect(test_class.to_gsm0338('—')).to eq('-')
    expect(test_class.to_gsm0338('’')).to eq("'")
    expect(test_class.to_gsm0338('$')).to eq('$')
  end
end
