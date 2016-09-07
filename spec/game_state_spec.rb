# encoding: UTF-8

# Read http://betterspecs.org/ for suggestions writing good specs.

RSpec.describe GameState do

  let(:player) { Player.new(PlayerColor::RED, '') }
  subject { GameState.new }

  it 'should perform moves' do
    oldState = subject.clone
    move = Move.new
    subject.perform(move, player)
    expect(oldState).to not_eq(subject)
  end

end
