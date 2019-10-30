# frozen_string_literal: true

require_relative '../../lib/software_challenge_client/util/constants'

module GameStateHelpers
  class BoardFormatError < StandardError
  end

  def state_from_string!(string, gamestate)
    fields = Board.new.field_list.sort do |a, b|
      cmp_z = a.coordinates.z <=> b.coordinates.z
      cmp_z == 0 ? a.coordinates.x <=> b.coordinates.x : cmp_z
    end.map { |f| { x: f.coordinates.x, y: f.coordinates.y } }
    field_descriptors = string.gsub(/\s/, '')
    board_fields = []
    fields.each_with_index do |c, i|
      board_fields << case field_descriptors[i * 2]
                      when 'R'
                        Field.new(
                          c[:x],
                          c[:y],
                          [Piece.new(PlayerColor::RED,
                                     PieceType.find_by_value(
                                       field_descriptors[i * 2 + 1]
                                     ))]
                        )
                      when 'B'
                        Field.new(
                          c[:x],
                          c[:y],
                          [Piece.new(PlayerColor::BLUE,
                                     PieceType.find_by_value(
                                       field_descriptors[i * 2 + 1]
                                     ))]
                        )
                      when 'O'
                        Field.new(c[:x], c[:y], [], true)
                      when '-'
                        Field.new(c[:x], c[:y])
                      else
                        raise BoardFormatError.new('Unknown field type')
                      end
    end
    gamestate.board = Board.new(board_fields)
  end
end
