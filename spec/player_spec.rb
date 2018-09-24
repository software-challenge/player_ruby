# encoding: UTF-8

# Read http://betterspecs.org/ for suggestions writing good specs.

RSpec.describe Player do
  subject(:player) { Player.new(PlayerColor::RED, 'name') }

  context 'when newly created' do
    it 'should have a color and a name' do
      expect(player.color).to eq(PlayerColor::RED)
      expect(player.name).to eq('name')
    end
  end
end
