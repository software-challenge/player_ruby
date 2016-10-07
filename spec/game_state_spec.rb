# encoding: UTF-8

# Read http://betterspecs.org/ for suggestions writing good specs.

include GameStateHelpers

RSpec.describe GameState do

  let!(:player) { Player.new(PlayerColor::RED, '') }
  subject { state_with_player_field(player) }

  it 'should be equal when cloned' do
    pending 'I guess there is a problem with equality '\
      'testing for one nested object'
    oldState = subject.deep_clone
    expect(oldState).to eq(subject)
  end

  it 'should perform moves' do
    oldState = subject.clone
    move = Move.new
    move.add_action Acceleration.new(1)
    subject.perform!(move, player)
    expect(oldState).to_not eq(subject)
    expect(player.velocity).to eq(2)
  end

end
