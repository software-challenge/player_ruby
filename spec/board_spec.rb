# encoding: UTF-8

# Read http://betterspecs.org/ for suggestions writing good specs.

include GameStateHelpers

RSpec.describe Board do
  let(:gamestate) { GameState.new }
  subject(:board) { gamestate.board }

  it 'should have fields initialized' do
    expect(board.field_list.size).to eq(Board::FIELD_AMOUNT)
  end

  xcontext 'method field' do
    before do
      field =
        <<~FIELD
          ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
          ~ ~ ~ ~ ~ ~ ~ B ~ ~
          ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
          ~ ~ ~ ~ ~ R ~ ~ ~ ~
          B ~ ~ O ~ ~ ~ ~ ~ ~
          ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
          ~ ~ ~ ~ ~ O ~ ~ ~ ~
          ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
          B ~ ~ ~ ~ ~ ~ ~ ~ ~
          ~ R ~ ~ ~ ~ ~ ~ R ~
        FIELD
      state_from_string!(field, gamestate)
    end

    it 'should return new invalid fields for indices out of range' do
      expect(board.field(99, 0)).to be_nil
      expect(board.field(2, -1)).to be_nil
    end

    it 'should return the field at the index' do
      field = Field.new(2, 3, FieldType::OBSTRUCTED)
      board.add_field(field)
      expect(board.field(2, 3)).to eq(field)
      expect(board.field(0, 0).type).to eq(FieldType::EMPTY)
      expect(board.field(0, 1).type).to eq(FieldType::BLUE)
      expect(board.field(0, 5).type).to eq(FieldType::BLUE)
      expect(board.field(7, 8).type).to eq(FieldType::BLUE)
      expect(board.field(1, 0).type).to eq(FieldType::RED)
      expect(board.field(8, 0).type).to eq(FieldType::RED)
      expect(board.field(5, 6).type).to eq(FieldType::RED)
      expect(board.field(8, 0).type).to eq(FieldType::RED)
      expect(board.field(5, 3).type).to eq(FieldType::OBSTRUCTED)
    end

    it 'counts red and blue fish correctly' do
      field =
        <<~FIELD
          ~ R R R ~ ~ ~ ~ ~ ~
          ~ ~ ~ ~ ~ ~ ~ R ~ ~
          ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
          ~ ~ ~ B ~ ~ ~ ~ ~ ~
          ~ ~ ~ B ~ ~ ~ ~ ~ ~
          ~ ~ ~ B ~ ~ ~ ~ ~ ~
          ~ ~ ~ B ~ O ~ ~ ~ ~
          ~ ~ ~ ~ B O ~ ~ ~ ~
          ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
          ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
        FIELD
      state_from_string!(field, gamestate)

      gamestate.add_player(Player.new(PlayerColor::RED, 'red player'))
      gamestate.add_player(Player.new(PlayerColor::BLUE, 'blue player'))
      gamestate.turn = 5
      gamestate.current_player_color = PlayerColor::BLUE
      Move.new(4, 2, Direction::LEFT).perform!(gamestate)

      expect(board.fields_of_type(FieldType::RED).size).to be 4
      expect(board.fields_of_type(FieldType::BLUE).size).to be 5
    end
  end
end
