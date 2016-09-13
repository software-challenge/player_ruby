# encoding: UTF-8

# Read http://betterspecs.org/ for suggestions writing good specs.

RSpec.describe Acceleration do

  let(:player) { Player.new(PlayerColor::RED, '') }
  let(:gamestate) { GameState.new }

  context 'when a player has velocity 6' do
    before { player.velocity = 6 }
    it 'should be invalid to accelerate' do
      expect {
        Acceleration.new(1).perform!(gamestate, player)
      }.to raise_error(InvalidMoveException)
    end
  end

  context 'when a player has velocity 1' do
    before { player.velocity = 1 }
    it 'should be invalid to decelerate' do
      expect {
        Acceleration.new(-1).perform!(gamestate, player)
      }.to raise_error(InvalidMoveException)
    end
  end
end

RSpec.describe Advance do
  include GameStateHelpers

  let(:gamestate) { GameState.new }

  it 'should not put the player on a blocked field' do
    text = <<-BOARD
      .W.W.W.W...
      ..W.B.W.W..
      ...W.W.W.W.
      ..r.B.W.W..
      .W.W.W.W...
    BOARD
    state_from_string!(-2, -2, text, gamestate)
    gamestate.red.direction = Direction::RIGHT

    expect {
      Advance.new(1).perform!(gamestate, gamestate.red)
    }.to raise_error(InvalidMoveException)
    expect {
      Advance.new(2).perform!(gamestate, gamestate.red)
    }.to raise_error(InvalidMoveException)
    gamestate.red.direction = Direction::UP_RIGHT
    expect {
      Advance.new(1).perform!(gamestate, gamestate.red)
    }.to_not raise_error(InvalidMoveException)
    expect {
      Advance.new(2).perform!(gamestate, gamestate.red)
    }.to raise_error(InvalidMoveException)
  end

  it 'should not move more than the players velocity' do
    text = <<-BOARD
      .W.W.W.W...
      ..b.W.W.W..
      ...W.W.W.W.
      ..r.W.W.W..
      .W.W.W.W...
    BOARD
    state_from_string!(-2, -2, text, gamestate)
    gamestate.red.direction = Direction::RIGHT
    gamestate.red.velocity = 2

    expect {
      Advance.new(3).perform!(gamestate, gamestate.red)
    }.to raise_error(InvalidMoveException)

  end

end
