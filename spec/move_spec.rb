# encoding: UTF-8

# Read http://betterspecs.org/ for suggestions writing good specs.

RSpec.describe Move do
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
end
