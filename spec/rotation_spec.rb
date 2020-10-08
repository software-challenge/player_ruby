# frozen_string_literal: true

# Read http://betterspecs.org/ for suggestions writing good specs.

RSpec.describe Rotation do
  subject(:board) { Board.new }

  describe 'rotate' do
    it 'can add two rotations together' do
      expect(Rotation::NONE.rotate(Rotation::LEFT)).to eq(Rotation::LEFT)
      expect(Rotation::NONE.rotate(Rotation::RIGHT)).to eq(Rotation::RIGHT)
      expect(Rotation::MIRROR.rotate(Rotation::LEFT)).to eq(Rotation::RIGHT)
      Rotation.to_a.each do |it|
        expect(it.rotate(Rotation::NONE)).to eq(it)
        expect(Rotation::NONE.rotate(it)).to eq(it)
        expect(it.rotate(Rotation::RIGHT).rotate(Rotation::LEFT)).to eq(it)
        expect(it.rotate(Rotation::MIRROR).rotate(Rotation::MIRROR)).to eq(it)
        expect(it.rotate(Rotation::LEFT).rotate(Rotation::LEFT)).to eq(it.rotate(Rotation::MIRROR))
      end
    end
  end
end
