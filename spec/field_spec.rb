# frozen_string_literal: true

# Read http://betterspecs.org/ for suggestions writing good specs.

include GameStateHelpers

RSpec.describe Field do
  subject(:field) { Field.new(0, 0) }

  it 'is empty without a color' do
    expect(field).to be_empty
  end

  it 'is not empty with a color' do
    field.color = Color::YELLOW
    expect(field).to_not be_empty
  end
end
