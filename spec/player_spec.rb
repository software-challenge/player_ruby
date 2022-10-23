# encoding: UTF-8
# frozen_string_literal: true

# Read http://betterspecs.org/ for suggestions writing good specs.

RSpec.describe Player do
  subject(:player) { Player.new(Team::ONE, 'uwu') }

  context 'when newly created' do
    it 'should have a team and a name' do
      expect(player.team).to eq(Team::ONE)
      expect(player.name).to eq('uwu')
    end
  end
end
