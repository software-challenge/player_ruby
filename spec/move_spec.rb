# encoding: utf-8
# frozen_string_literal: true

# Read http://betterspecs.org/ for suggestions writing good specs.

RSpec.describe Move do
  include GameStateHelpers

  subject(:move) { Move.new(1, 0, Direction::UP) }

  it 'should be equal to a move with the same coordinates and direction' do
    other = described_class.new(1, 0, Direction::UP)
    other.add_hint(DebugHint.new('hint'))
    move.add_hint(DebugHint.new('hint'))
    expect(move).to eq(other)
  end

  context 'with a gamestate' do
    before do
      field =
        <<~FIELD
          ~ R R R R R R R R ~
          B ~ ~ ~ ~ ~ ~ ~ ~ B
          B ~ ~ ~ ~ ~ ~ ~ ~ B
          B ~ ~ ~ ~ ~ ~ ~ ~ B
          B ~ ~ O ~ ~ ~ ~ ~ B
          B ~ ~ ~ ~ ~ ~ ~ ~ B
          B ~ ~ ~ ~ O ~ ~ ~ B
          B ~ ~ ~ ~ O ~ ~ ~ B
          B ~ ~ ~ ~ ~ ~ ~ ~ B
          ~ R R R R R R R R ~
        FIELD
      state_from_string!(field, gamestate)
      gamestate.add_player(Player.new(PlayerColor::RED, 'red player'))
      gamestate.add_player(Player.new(PlayerColor::BLUE, 'blue player'))
    end

    let(:gamestate) { GameState.new }

    it 'is possible to check validity of move instance' do
      expect(move.valid?(gamestate)).to be true
    end

    describe '#perform!' do
      subject { move.perform!(gamestate) }

      context 'when valid' do
        it { expect { subject }.not_to raise_error }

        it do
          target = GameRuleLogic.move_target(move, gamestate.board)
          expect { subject }
            .to change { gamestate.board.field(move.x, move.y).type }
            .from(FieldType::RED)
            .to(FieldType::EMPTY)
            .and change { gamestate.board.field(target.x, target.y).type }
            .from(FieldType::EMPTY)
            .to(FieldType::RED)
        end

        it do
          expect { subject }
            .to change { gamestate.current_player }
            .from(gamestate.red)
            .to(gamestate.blue)
        end

        it do
          expect { subject }
            .to change { gamestate.last_move }
            .to(move)
        end

        it do
          expect { subject }
            .to change { gamestate.turn }
            .by(1)
        end
      end

      context 'with a winning move' do
        before do
          field =
            <<~FIELD
              ~ R R R ~ ~ ~ ~ ~ ~
              ~ ~ ~ ~ ~ ~ ~ R ~ ~
              ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
              ~ ~ ~ B ~ ~ ~ ~ ~ ~
              ~ ~ ~ B ~ ~ ~ ~ ~ ~
              ~ ~ ~ B ~ ~ ~ ~ ~ ~
              ~ ~ ~ B ~ O ~ ~ ~ ~
              ~ ~ ~ ~ B O ~ ~ ~ ~
              ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
              ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
            FIELD
          state_from_string!(field, gamestate)
          gamestate.add_player(Player.new(PlayerColor::RED, 'red player'))
          gamestate.add_player(Player.new(PlayerColor::BLUE, 'blue player'))
          gamestate.turn = 5
          gamestate.current_player_color = PlayerColor::BLUE
        end

        let(:move) { Move.new(4, 2, Direction::LEFT) }

        it 'indicates a win' do
          expect { subject }
            .to change { gamestate.condition&.winner }
            .from(nil)
            .to(PlayerColor::BLUE)
        end
      end

      context 'when invalid' do
        let(:move) { Move.new(1, 0, Direction::DOWN) } # this is an invalid move
        it { expect { subject }.to raise_error(InvalidMoveException) }
      end
    end
  end
end
