# frozen_string_literal: true

# Read http://betterspecs.org/ for suggestions writing good specs.

RSpec.describe Field do
  subject(:field) { Field.new(0, 0, Piece.new(Team::ONE)) }

  it 'is empty without a piece' do
    expect(Field.new(0, 0)).to be_empty
  end

  it 'is not empty' do
    expect(field).to_not be_empty
  end

  it 'has coordinates' do
    expect(field.x).to eq(0)
    expect(field.y).to eq(0)
  end

  it 'is comparable' do
    expect(field).to eq(Field.new(0, 0, Piece.new(Team::ONE)))
  end
end
