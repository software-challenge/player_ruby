module GameStateHelpers

  class BoardFormatError < StandardError;
  end

  def state_from_string!(string, gamestate)
    board = Board.new
    red = nil
    blue = nil
    string.split(/\s+/).each_with_index do |field, index|
      if field.length > 3
        raise BoardFormatError,
              "too many identifiers for field ##{index}: '#{field}'"
      end
      if field.length > 1
        if field.length == 3 && !%w(0 G).include?(field.gsub(/[rb]/, ''))
          raise BoardFormatError,
                'both players are only allowed on start and goal'
        end
        if field.include? 'r'
          red = Player.new(PlayerColor::RED, '')
          red.index = index
        end
        if field.include? 'b'
          blue = Player.new(PlayerColor::BLUE, '')
          blue.index = index
        end
        field.gsub!(/[rb]/, '')
        if field.empty?
          raise BoardFormatError, "no type for field ##{index}: '#{field}'"
        end
        if field.length == 2
          raise BoardFormatError,
                "multiple types for field ##{index}: '#{field}'"
        end
      end
      type = nil
      case field[0]
        when '1'
          type = FieldType::POSITION_1
        when '2'
          type = FieldType::POSITION_2
        when 'I'
          type = FieldType::HEDGEHOG
        when 'S'
          type = FieldType::SALAD
        when 'C'
          type = FieldType::CARROT
        when 'H'
          type = FieldType::HARE
        when 'X'
          type = FieldType::INVALID
        when 'G'
          type = FieldType::GOAL
        when '0'
          type = FieldType::START
        else
          raise BoardFormatError, "unexpected field type '#{c}' at ##{index}"
      end
      board.add_field(Field.new(type, index))
    end
    gamestate.board = board
    # A board without both players should raise an error because the game rule code also expects that both players are
    # present and not having them would lead to failing tests because unrealistic situations are tested.
    raise BoardFormatError, "no red player found" if red.nil?
    gamestate.add_player(red)
    raise BoardFormatError, "no blue player found" if blue.nil?
    gamestate.add_player(blue)
  end
end
