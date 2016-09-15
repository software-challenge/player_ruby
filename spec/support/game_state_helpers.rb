module GameStateHelpers

  def state_from_string!(start_x, start_y, string, gamestate)
    board = Board.new
    red = nil
    blue = nil
    x = start_x
    y = start_y
    line_start = true
    last_was_field = false
    # NOTE that this will likely not work for UTF8 characters
    string.each_char do |c|
      case c
      when ' '
        # ignore whitespace
      when '.'
        if line_start && y.even?
          # offset
          line_start = false
          last_was_field = false
        elsif last_was_field
          # fieldseparator
          last_was_field = false
        else
          # unoccupied field
          last_was_field = true
          x += 1
        end
      when "\n"
        line_start = true
        last_was_field = false
        x = start_x
        y += 1
      else
        type = nil
        case c
        when 'W', 'r', 'b', '8'
          # 'r' and 'b' may be used to mark players positions,
          # '8' when both players are on the same field
          type = FieldType::WATER
          if c == 'r' || c == '8'
            red = Player.new(PlayerColor::RED, '')

            red.x = x
            red.y = y
          end
          if c == 'b' || c == '8'
            blue = Player.new(PlayerColor::BLUE, '')
            blue.x = x
            blue.y = y
          end
        when 'B'
          type = FieldType::BLOCKED
        when 'S'
          type = FieldType::SANDBANK
        when 'L'
          type = FieldType::LOG
        when 'G'
          type = FieldType::GOAL
        when '0'
          type = FieldType::PASSENGER0
        when '1'
          type = FieldType::PASSENGER1
        when '2'
          type = FieldType::PASSENGER2
        when '3'
          type = FieldType::PASSENGER3
        when '4'
          type = FieldType::PASSENGER4
        when '5'
          type = FieldType::PASSENGER5
        else
          raise "unexpected field type '#{c}' at (#{x}, #{y})"
        end
        board.add_field(Field.new(type, x, y, 0, Direction::RIGHT, 0))
        line_start = false
        last_was_field = true
        x += 1
      end
    end
    gamestate.board = board
    gamestate.add_player(red) unless red.nil?
    gamestate.add_player(blue) unless blue.nil?
  end

end
