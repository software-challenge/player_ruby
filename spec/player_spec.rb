# encoding: UTF-8

# Read http://betterspecs.org/ for suggestions writing good specs.

RSpec.describe Player do
  subject(:player) { Player.new(PlayerColor::RED, '') }

  context 'when newly created' do
    it 'should have all cards, 68 carrots and two salads' do
      expect(player.cards).to eq([
                                   CardType::TAKE_OR_DROP_CARROTS,
                                   CardType::EAT_SALAD,
                                   CardType::FALL_BACK,
                                   CardType::HURRY_AHEAD
                                 ])
      expect(player.salads).to eq(2)
      expect(player.carrots).to eq(68)
    end

    it 'should be on field with index 0' do
      expect(player.index).to eq(0)
    end
  end
end
