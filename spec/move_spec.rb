# encoding: UTF-8

# Read http://betterspecs.org/ for suggestions writing good specs.

RSpec.describe Move do

  include GameStateHelpers

  subject(:move) { described_class.new }

  it 'should accept actions to be added' do
    move.add_action(Acceleration.new(3))
    expect(move.actions.size).to eq(1)
  end

  it 'should be equal to a move with the same actions' do
    other = described_class.new
    other.add_action(Acceleration.new(2))
    other.add_action(Turn.new(1))
    other.add_action(Advance.new(3))
    other.add_action(Push.new(-1))
    other.add_hint(DebugHint.new('hint'))
    move.add_action(Acceleration.new(2))
    move.add_action(Turn.new(1))
    move.add_action(Advance.new(3))
    move.add_action(Push.new(-1))
    expect(move).to eq(other)
  end

  context 'moving onto a sandbank' do

    let(:gamestate) { GameState.new }

    before do
      text = <<-BOARD
      .W.W.W.W...
      ..b.W.S.W..
      ...W.W.W.W.
      ..r.W.W.W..
      .W.W.W.W...
      BOARD
      state_from_string!(-2, -2, text, gamestate)
    end

    it 'is only allowed as last action' do
      gamestate.current_player_color = PlayerColor::BLUE
      move.add_action(Acceleration.new(2))
      move.add_action(Advance.new(3))
      expect {
        move.perform!(gamestate, gamestate.current_player)
      }.to raise_error(InvalidMoveException)
      move = Move.new
      move.add_action(Acceleration.new(2))
      move.add_action(Advance.new(2))
      expect {
        move.perform!(gamestate, gamestate.current_player)
      }.not_to raise_error
    end
  end

  context 'accelerating' do

    let(:gamestate) do
      state = GameState.new
      state.add_player(Player.new(PlayerColor::RED, ''))
      state
    end

    it 'should increase movement and velocity' do
      move.add_action(Acceleration.new(1))
      move.add_action(Acceleration.new(1))
      expect {
        move.perform!(gamestate, gamestate.current_player)
      }.to change(gamestate.current_player, :velocity).by(2)
       .and change(gamestate.current_player, :movement).by(2)
    end

    it 'is only allowed as first action in move' do
      text = <<-BOARD
      .W.W.W.W...
      ..b.W.W.W..
      ...W.W.W.W.
      ..r.W.W.W..
      .W.W.W.W...
      BOARD
      state_from_string!(-2, -2, text, gamestate)
      move.add_action(Acceleration.new(1))
      move.add_action(Acceleration.new(1))
      move.add_action(Advance.new(1))
      expect {
        move.perform!(gamestate, gamestate.current_player)
      }.not_to raise_error
      move.add_action(Acceleration.new(1))
      expect {
        move.perform!(gamestate, gamestate.current_player)
      }.to raise_error(InvalidMoveException)
    end
  end
end
