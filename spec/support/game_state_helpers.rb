# frozen_string_literal: true

require_relative '../../lib/software_challenge_client/util/constants'
require_relative '../../lib/software_challenge_client/color'

module GameStateHelpers
  include Constants

  class BoardFormatError < StandardError
  end

  def field_from_descriptor(coordinates, descriptor)
    color = if descriptor == '_'
              nil
            else
              unless Color.to_a.map(&:value).include? descriptor
                raise BoardFormatError.new("unknown field descriptor #{descriptor}")
              end

              Color.find_by_value(descriptor)
            end
    Field.new(coordinates.x, coordinates.y, color)
  end

  # NOTE that this currently does not update undeployed pieces!
  def state_from_string!(string, gamestate)
    fields = Board.new.field_list
    field_descriptors = string.gsub(/\s/, '')
    board_fields = []
    fields.each do |field|
      board_fields << field_from_descriptor(field.coordinates, field_descriptors[field.y * BOARD_SIZE + field.x])
    end
    gamestate.ordered_colors = [ Color::BLUE, Color::YELLOW, Color::RED, Color::GREEN ]
    gamestate.start_piece = PieceShape::PENTO_V
    gamestate.turn = 4
    gamestate.round = 2
    gamestate.board = Board.new(board_fields)
  end
end
