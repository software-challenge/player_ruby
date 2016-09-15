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

  it 'should not cost coal to accelerate once' do
    expect {
      Acceleration.new(1).perform!(gamestate, player)
    }.to_not change { player.coal }
  end

  it 'should not cost coal to accelerate by two' do
    expect {
      Acceleration.new(2).perform!(gamestate, player)
    }.to change { player.coal }.by(-1)
  end

  it 'should not cost coal to accelerate twice' do
    expect {
      Acceleration.new(1).perform!(gamestate, player)
      Acceleration.new(1).perform!(gamestate, player)
    }.to change { player.coal }.by(-1)
  end
end

RSpec.describe Advance do
  include GameStateHelpers

  let(:gamestate) { GameState.new }

  it 'should not put the player on a blocked field' do
    text = <<-BOARD
      .W.W.W.W...
      ..b.B.W.W..
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
    }.not_to raise_error
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

  it 'should not move over a field occupied by opponent' do
    text = <<-BOARD
      .W.W.W.W...
      ..W.W.W.W..
      ...W.W.W.W.
      ..r.W.b.W..
      .W.W.W.W...
    BOARD
    state_from_string!(-2, -2, text, gamestate)
    gamestate.red.direction = Direction::RIGHT
    gamestate.red.velocity = 4
    expect(gamestate.current_player).to eq(gamestate.red)

    expect {
      Advance.new(3).perform!(gamestate, gamestate.red)
    }.to raise_error(InvalidMoveException)
    expect {
      Advance.new(2).perform!(gamestate, gamestate.red)
    }.not_to raise_error
  end

  it 'should move onto a field occupied by opponent' do
    text = <<-BOARD
      .W.W.W.W...
      ..W.W.W.W..
      ...W.W.W.W.
      ..r.W.b.W..
      .W.W.W.W...
    BOARD
    state_from_string!(-2, -2, text, gamestate)
    gamestate.red.direction = Direction::RIGHT
    gamestate.red.velocity = 3

    expect {
      Advance.new(2).perform!(gamestate, gamestate.red)
    }.not_to raise_error

    # moving onto player costs one more movement, having velocity equal to the
    # number of fields moved should not be enough
    gamestate.red.velocity = 2

    expect {
      Advance.new(2).perform!(gamestate, gamestate.red)
    }.to raise_error(InvalidMoveException)
  end

  it 'is not negative' do
    text = <<-BOARD
      .W.W.W.W...
      ..W.b.W.W..
      ...W.W.W.W.
      ..W.W.r.W..
      .W.W.W.W...
    BOARD
    state_from_string!(-2, -2, text, gamestate)
    gamestate.red.direction = Direction::RIGHT
    gamestate.red.velocity = 3
    expect {
      Advance.new(-1).perform!(gamestate, gamestate.red)
    }.to raise_error(InvalidMoveException)
  end
end

RSpec.describe Turn do

  let!(:player) { Player.new(PlayerColor::RED, '') }
  let(:gamestate) do
    state = GameState.new
    state.board.add_field(Field.new(FieldType::WATER, 0, 0, 0, 0, 0))
    player.x = 0
    player.y = 0
    player.direction = Direction::RIGHT
    state.add_player(player)
    state
  end

  it 'should change the players direction' do
    expect {
      Turn.new(-1).perform!(gamestate, player)
    }.to change { player.direction }.to(Direction::DOWN_RIGHT)
  end

  it 'should not be possible on sandbanks' do
    gamestate.board.add_field(Field.new(FieldType::SANDBANK, player.x, player.y, 0, 0, 0))
    expect {
      Turn.new(1).perform!(gamestate, player)
    }.to raise_error(InvalidMoveException)
  end

  it 'should cost coal after one free turn' do
    expect {
      Turn.new(2).perform!(gamestate, player)
    }.to change { player.coal }.by(-1)
    expect {
      Turn.new(1).perform!(gamestate, player)
    }.to change { player.coal }.by(-1)
  end

  context 'when been pushed' do

    before { gamestate.additional_free_turn_after_push = true }

    it 'should not cost coal for two turns' do
      expect {
        Turn.new(2).perform!(gamestate, player)
      }.not_to change { player.coal }
      expect {
        Turn.new(1).perform!(gamestate, player)
      }.to change { player.coal }.by(-1)
    end

    it 'should not cost coal for two separate turns by 1' do
      expect {
        Turn.new(1).perform!(gamestate, player)
        Turn.new(1).perform!(gamestate, player)
      }.not_to change { player.coal }
      expect {
        Turn.new(1).perform!(gamestate, player)
      }.to change { player.coal }.by(-1)
    end
  end

end
