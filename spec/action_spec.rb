# encoding: UTF-8

# Read http://betterspecs.org/ for suggestions writing good specs.

# Needed when chaining matchers. expect(...).not_to raise_error().and .. is not
# allowed.
RSpec::Matchers.define_negated_matcher :not_raise_error, :raise_error

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

  it 'should not move more than the players movement points' do
    text = <<-BOARD
      .W.W.W.W...
      ..b.W.W.W..
      ...W.W.W.W.
      ..r.W.W.W..
      .W.W.W.W...
    BOARD
    state_from_string!(-2, -2, text, gamestate)
    gamestate.red.direction = Direction::RIGHT
    gamestate.red.movement = 2

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
    gamestate.red.movement = 4
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
    gamestate.red.movement = 3

    expect {
      Advance.new(2).perform!(gamestate, gamestate.red)
    }.not_to raise_error

    # moving onto player costs one more movement, having points equal to the
    # number of fields moved should not be enough
    gamestate.red.movement = 2

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
    gamestate.red.movement = 3
    expect {
      Advance.new(-1).perform!(gamestate, gamestate.red)
    }.to raise_error(InvalidMoveException)
  end

  it 'costs one more movement when moving over logs' do
    text = <<-BOARD
      .W.W.W.W...
      ..W.b.W.W..
      ...W.W.W.W.
      ..W.r.L.W..
      .W.W.W.W...
    BOARD
    state_from_string!(-2, -2, text, gamestate)
    gamestate.red.direction = Direction::RIGHT
    # velocity should not be considered, set it to a high value to 'test' this
    gamestate.red.velocity = 3
    gamestate.red.movement = 1
    expect {
      Advance.new(1).perform!(gamestate, gamestate.red)
    }.to raise_error(InvalidMoveException)
    gamestate.red.movement = 2
    expect {
      Advance.new(1).perform!(gamestate, gamestate.red)
    }.to not_raise_error.and change{ gamestate.red.movement }.by(-2)
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

RSpec.describe Push do
  include GameStateHelpers

  let(:gamestate) { GameState.new }

  it 'should only be possible when on other player' do
    text = <<-BOARD
      .W.W.W.W...
      ..W.b.W.W..
      ...W.W.W.W.
      ..W.W.r.W..
      .W.W.W.W...
    BOARD
    state_from_string!(-2, -2, text, gamestate)
    expect {
      Push.new(Direction::RIGHT).perform!(gamestate, gamestate.current_player)
    }.to raise_error(InvalidMoveException)
  end

  it 'should not be allowed to push other player behind' do
    text = <<-BOARD
        .W.W.W.W...
        ..W.8.W.W..
        ...W.W.W.W.
        ..W.W.W.W..
        .W.W.W.W...
      BOARD
    state_from_string!(-2, -2, text, gamestate)
    gamestate.current_player.direction = Direction::DOWN_RIGHT
    expect {
      Push.new(Direction::UP_LEFT).perform!(gamestate, gamestate.current_player)
    }.to raise_error(InvalidMoveException)
  end

  it 'costs one movement' do
    text = <<-BOARD
        .W.W.W.W...
        ..W.8.W.W..
        ...W.W.W.W.
        ..W.W.W.W..
        .W.W.W.W...
      BOARD
    state_from_string!(-2, -2, text, gamestate)
    gamestate.current_player.direction = Direction::DOWN_RIGHT
    gamestate.current_player.movement = 3
    expect {
      Push.new(Direction::RIGHT).perform!(gamestate, gamestate.current_player)
    }.to change { gamestate.current_player.movement }.by(-1)
    gamestate.current_player.movement = 0
    expect {
      Push.new(Direction::RIGHT).perform!(gamestate, gamestate.current_player)
    }.to raise_error(InvalidMoveException)
  end

  it 'should move the opponent in the specified direction' do
    text = <<-BOARD
        .W.W.W.W...
        ..W.8.W.W..
        ...W.W.W.W.
        ..W.W.W.W..
        .W.W.W.W...
      BOARD
    state_from_string!(-2, -2, text, gamestate)
    gamestate.current_player.direction = Direction::DOWN_RIGHT
    gamestate.current_player.velocity = 1
    Push.new(Direction::RIGHT).perform!(gamestate, gamestate.current_player)
    expect(gamestate.other_player.x).to eq(1)
    expect(gamestate.other_player.y).to eq(-1)
  end


  it 'costs two movement when pushing into logs' do
    text = <<-BOARD
        .W.W.W.W...
        ..W.8.L.W..
        ...W.W.W.W.
        ..W.W.W.W..
        .W.W.W.W...
      BOARD
    state_from_string!(-2, -2, text, gamestate)
    gamestate.current_player.direction = Direction::DOWN_RIGHT
    gamestate.current_player.movement = 2
    expect {
      Push.new(Direction::RIGHT).perform!(gamestate, gamestate.current_player)
    }.to not_raise_error.and change {gamestate.current_player.movement}.by(-2)
    gamestate.current_player.movement = 1
    expect {
      Push.new(Direction::RIGHT).perform!(gamestate, gamestate.current_player)
    }.to raise_error(InvalidMoveException)
  end

  it 'is not possible when on a sandbank' do
    text = <<-BOARD
        .W.W.W.W...
        ..W.8.W.W..
        ...W.W.W.W.
        ..W.W.W.W..
        .W.W.W.W...
      BOARD
    state_from_string!(-2, -2, text, gamestate)
    gamestate.current_player.direction = Direction::DOWN_RIGHT
    gamestate.current_player.movement = 2
    gamestate.board.fields[0][-1] = Field.new(FieldType::SANDBANK, 0, -1, 0, 0, 0)

    expect {
      Push.new(Direction::RIGHT).perform!(gamestate, gamestate.current_player)
    }.to raise_error(InvalidMoveException)
  end

end
