# frozen_string_literal: true

# Read http://betterspecs.org/ for suggestions writing good specs.

include GameStateHelpers

RSpec.describe Field do
  subject(:field) { Field.new(0, 0, Piece.new(Color::RED, PieceType::COCKLE)) }

  it 'is empty without a color' do
    expect(field).to be_empty
  end

  it 'is not empty with a color' do
    field.piece.set_color(Color::RED)
    expect(field).to_not be_empty
  end

  it 'has coordinates' do
    expect(field.x).to eq(0)
    expect(field.y).to eq(0)
  end

  it 'is comparable' do
    field.piece.set_color(Color::RED)
    expect(field).to eq(Field.new(0, 0, Color::RED))
  end
end
