module GameStateHelpers

  class BoardFormatError < StandardError; end

  def state_from_string!(string, gamestate)
    board = Board.new
    red = nil
    blue = nil
    string.split(/\s+/).each_with_index do |field, index|
      raise BoardFormatError.new("too many identifiers for field ##{index}: '#{field}'") if field.length > 3
      if field.length > 1
        raise BadFormatError.new("both players are only allowed on start and goal") if field.length == 3 && !['0', 'G'].include?(field.gsub(/[rb]/,''))
        if field.include? 'r'
          red = Player.new(PlayerColor::RED, '')
          red.index = index
        end
        if field.include? 'b'
          blue = Player.new(PlayerColor::BLUE, '')
          blue.index = index
        end
        field.gsub!(/[rb]/, '')
        raise BoardFormatError.new("no type for field ##{index}: '#{field}'") if field.length == 0
        raise BoardFormatError.new("multiple types for field ##{index}: '#{field}'") if field.length == 2
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
        raise BoardFormatError.new("unexpected field type '#{c}' at ##{index}")
      end
      board.add_field(Field.new(type, index))
    end
    gamestate.board = board
    gamestate.add_player(red) unless red.nil?
    gamestate.add_player(blue) unless blue.nil?
  end
end
