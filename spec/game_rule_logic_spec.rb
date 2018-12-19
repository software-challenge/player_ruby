# encoding: UTF-8

# Read http://betterspecs.org/ for suggestions writing good specs.

# Needed when chaining matchers. expect(...).not_to raise_error().and .. is not
# allowed.
RSpec::Matchers.define_negated_matcher :not_raise_error, :raise_error

# matcher to make game rule specs nicer to read
RSpec::Matchers.define :be_valid_to do |what, *args|
  match do |actual|
    actual.send('is_valid_to_' + what.to_s, *args)[0]
  end
end
RSpec::Matchers.define_negated_matcher :not_be_valid_to, :be_valid_to

include GameStateHelpers

RSpec.describe GameRuleLogic do

  subject { GameRuleLogic }
  let(:gamestate) { GameState.new }

  context 'on game start' do
    before do
      field =
        <<~FIELD
          ~ R R R R R R R R ~
          B ~ ~ ~ ~ ~ ~ ~ ~ B
          B ~ ~ ~ ~ ~ ~ ~ ~ B
          B ~ ~ ~ ~ ~ ~ ~ ~ B
          B ~ ~ O ~ ~ ~ ~ ~ B
          B ~ ~ ~ ~ ~ ~ ~ ~ B
          B ~ ~ ~ ~ O ~ ~ ~ B
          B ~ ~ ~ ~ O ~ ~ ~ B
          B ~ ~ ~ ~ ~ ~ ~ ~ B
          ~ R R R R R R R R ~
        FIELD
      state_from_string!(field, gamestate)
    end

    it 'is valid to move own fish' do
      expect(subject.valid_move?(Move.new(1, 0, Direction::UP), gamestate.board, gamestate.current_player_color)).to be true
    end

    it 'is not valid to move an empty field' do
      expect(subject.valid_move?(Move.new(2, 1, Direction::UP), gamestate.board, gamestate.current_player_color)).to be false
    end

    it 'is not valid to move an obstructed field' do
      expect(
        subject.valid_move?(Move.new(5, 3, Direction::RIGHT), gamestate.board, gamestate.current_player_color)
      ).to be false
    end

    it 'is not valid to move onto an obstructed field' do
      expect(subject.valid_move?(Move.new(5, 0, Direction::UP), gamestate.board, gamestate.current_player_color)).to be false
    end

    it 'is not valid to move out of the board' do
      expect(subject.valid_move?(Move.new(5, 0, Direction::DOWN), gamestate.board, gamestate.current_player_color)).to be false
    end

    it 'calculates all valid moves for a given field' do
      expect(
        subject.possible_moves(gamestate.board, gamestate.board.field(1, 0), PlayerColor::RED)
      ).to contain_exactly(
        Move.new(1, 0, Direction::UP),
        Move.new(1, 0, Direction::UP_RIGHT),
        Move.new(1, 0, Direction::RIGHT)
      )
    end
  end

  it 'calculates correct swarm size' do
    field =
      <<~FIELD
          ~ R R R R B R R R ~
          B R R R ~ ~ ~ ~ ~ ~
          B ~ ~ ~ R ~ ~ ~ ~ ~
          B ~ ~ ~ ~ ~ ~ ~ ~ ~
          B ~ ~ O ~ ~ ~ ~ ~ ~
          B B B ~ ~ ~ ~ ~ ~ ~
          B ~ ~ ~ ~ O ~ ~ ~ B
          B ~ ~ ~ ~ O ~ ~ ~ B
          B ~ ~ ~ ~ ~ ~ ~ ~ B
          ~ R R ~ R ~ R R R ~
        FIELD
    state_from_string!(field, gamestate)
    expect(subject.swarm_size(gamestate.board, PlayerColor::RED)).to eq(8)
    expect(subject.swarm_size(gamestate.board, PlayerColor::BLUE)).to eq(10)
  end

  it 'calculates correct swarm size with very few fishes' do
    # this is an edge case to capture Issue #12
    field =
      <<~FIELD
          ~ R ~ ~ ~ ~ ~ ~ ~ ~
          ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
          ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
          ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
          ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
          ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
          ~ ~ ~ ~ ~ O ~ ~ ~ ~
          ~ ~ ~ ~ ~ O ~ ~ ~ ~
          ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
          ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
        FIELD
    state_from_string!(field, gamestate)
    expect(subject.swarm_size(gamestate.board, PlayerColor::RED)).to eq(1)
    expect(subject.swarm_size(gamestate.board, PlayerColor::BLUE)).to eq(0)
  end

  describe '#winning_condition' do
    before do
      field =
        <<~FIELD
          ~ R R R ~ ~ ~ ~ ~ ~
          ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
          ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
          ~ ~ ~ B ~ ~ ~ ~ ~ ~
          ~ ~ ~ B ~ ~ ~ ~ ~ ~
          ~ ~ ~ B ~ ~ ~ ~ ~ ~
          ~ ~ ~ B ~ O ~ ~ ~ ~
          ~ ~ ~ ~ ~ O ~ ~ ~ ~
          ~ ~ ~ B ~ ~ ~ ~ ~ ~
          ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
        FIELD
      state_from_string!(field, gamestate)
    end

    context 'when red has only one swarm and blue made it\'s turn after that already' do
      before do
        # red made the swarm complete in turn 0, blue made a turn (1), round is
        # complete and it's red's turn again (turn 2)
        gamestate.turn = 2
      end

      it 'declares red as the winner' do
        expect(subject.winning_condition(gamestate)).not_to be_nil
        expect(subject.winning_condition(gamestate).winner).to eq(PlayerColor::RED)
      end
    end

    context 'when red has only one swarm and blue has not made it\'s turn after that' do
      before do
        # red made the swarm complete in turn 0, blue can make a turn (1) before
        # the round is complete
        gamestate.turn = 1
      end

      it 'declares no winner' do
        gamestate.turn = 1
        expect(subject.winning_condition(gamestate)).to be_nil
      end
    end
  end
end
