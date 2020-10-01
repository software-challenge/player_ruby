# frozen_string_literal: true

# Read http://betterspecs.org/ for suggestions writing good specs.

include GameStateHelpers
include Constants

RSpec.describe Board do
  subject(:board) { Board.new }

  it 'should have fields initialized' do
    expect(board.field_list.size).to eq(BOARD_SIZE**2)
  end

  it 'should be cloneable' do
    expect(board.clone).to eq(board)
  end

  it 'should be comparable' do
    clone = board.clone
    expect(clone).to eq(board)
    clone.field(0, 0).color = Color::YELLOW
    expect(clone).not_to eq(board)
  end

  it 'should have fields with correct coordinates' do
    c = Coordinates.new(3, 1)
    expect(board.field_at(c).coordinates).to eq(c)
  end
end
