# frozen_string_literal: true

require_relative '../../lib/software_challenge_client/util/constants'

module GameStateHelpers
  include Constants

  class BoardFormatError < StandardError
  end

  def field_from_descriptor(coords, descriptor)
    piece = nil
    fishes = 0

    if descriptor != '_'
      unless descriptor[0] >= '0' && descriptor[0] <= '4' && descriptor[0] != 'O' && descriptor[0] != 'T'
        raise BoardFormatError.new("unknown descriptor #{descriptor[0]}")
      end
      
      if descriptor[0] == 'O'
        piece = Piece.new(coords.x, coords.y, Team::ONE)
      elsif descriptor[0] != 'T'
        piece = Piece.new(coords.x, coords.y, Team::TWO)
      else
        fishes = descriptor[0].to_i
      end
    end
    
    Field.new(coords.x, coords.y, piece)
  end

  # NOTE that this currently does not update undeployed pieces!
  def state_from_string!(string, gamestate)
    fields = Board.new.field_list
    field_descriptors = string.split(' ')
    board_fields = []
    fields.each do |field|
      board_fields << field_from_descriptor(field.coords, field_descriptors[field.y * BOARD_SIZE + field.x])
    end
    gamestate.turn = 4
    gamestate.add_player(Player.new(Team::ONE, "ONE", 0))
    gamestate.add_player(Player.new(Team::TWO, "TWO", 0))
    gamestate.current_player = gamestate.player_two
    gamestate.board = Board.new(board_fields)
  end
end
