require_relative '../../lib/software_challenge_client/util/constants'

module GameStateHelpers

  class BoardFormatError < StandardError;
  end

  def state_from_string!(string, gamestate)
    board = Board.new
    string.lines.each_with_index do |row, y|
      row.split(/\s+/).each_with_index do |field, x|
        if field.length > 1
          raise boardformaterror,
                "too many identifiers for field (#{x},#{y}): '#{field}'"
        end
        type =
          case field
          when '~'
            FieldType::EMPTY
          when 'R'
            FieldType::RED
          when 'B'
            FieldType::BLUE
          when 'O'
            FieldType::OBSTRUCTED
          else
            raise boardformaterror,
                  "unknown identifier for field (#{x},#{y}): '#{field}'"
          end
        board.add_field(Field.new(x, Constants::SIZE - 1 - y, type))
      end
    end
    gamestate.board = board
  end
end
