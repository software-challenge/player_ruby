# encoding: UTF-8

# Read http://betterspecs.org/ for suggestions writing good specs.

RSpec.describe GameState do

  let(:player) { Player.new(PlayerColor::RED, '') }
  subject { GameState.new }

  it 'should be equal when cloned' do
    oldState = subject.clone
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
