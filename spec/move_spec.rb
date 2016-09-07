# encoding: UTF-8

# Read http://betterspecs.org/ for suggestions writing good specs.

RSpec.describe Move do
  subject { Move.new }

  it 'should accept actions to be added' do
    subject.add_action(Acceleration.new(3))
    expect(subject.actions.size).to eq(1)
  end

  it 'should be equal to a move with the same actions' do
    other = Move.new
    other.add_action(Acceleration.new(2))
    other.add_action(Turn.new(1))
    other.add_action(Advance.new(3))
    other.add_action(Push.new(-1))
    other.add_hint(DebugHint.new('hint'))
    subject.add_action(Acceleration.new(2))
    subject.add_action(Turn.new(1))
    subject.add_action(Advance.new(3))
    subject.add_action(Push.new(-1))
    expect(subject).to eq(other)
  end
end
