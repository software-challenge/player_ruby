# encoding: UTF-8

# Read http://betterspecs.org/ for suggestions writing good specs.

# Needed when chaining matchers. expect(...).not_to raise_error().and .. is not
# allowed.
RSpec::Matchers.define_negated_matcher :not_raise_error, :raise_error

include GameStateHelpers

RSpec.describe Advance do

  let(:gamestate) { GameState.new }

  context 'when a player is on start field' do
    before { state_from_string!('r0 C C C C C C C C C C C C G', gamestate) }

    it 'should be valid to advance' do
      expect {
        Advance.new(1).perform!(gamestate)
      }.not_to raise_error
    end

    it 'should change the players position when advancing' do
      expect {
        Advance.new(1).perform!(gamestate)
      }.to change{gamestate.current_player.index}.from(0).to(1)
    end

    it 'should change the players carrots when advancing' do
      expect {
        Advance.new(3).perform!(gamestate)
      }.to change{gamestate.current_player.carrots}.by(-6)
    end

    it 'should not be possible to move past field 11' do
      expect {
        Advance.new(12).perform!(gamestate)
      }.to raise_error(InvalidMoveException, /Nicht genug Karotten/)
    end

    it 'should not be possible to move past the last field with unlimited carrots' do
      gamestate.current_player.carrots = 9999
      expect {
        Advance.new(14).perform!(gamestate)
      }.to raise_error(InvalidMoveException, /Feld.+nicht vorhanden/)
    end
  end
end
