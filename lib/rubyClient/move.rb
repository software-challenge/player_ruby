require_relative 'debug_hint'

class Move
  attr_reader :x
  attr_reader :y
  attr_reader :hints
  
  def initialize
    self.x = -1
    self.y = -1
  end
  
  def initialize(x, y)
    @x = x
    @y = y
    @hints = Array.new
  end
  
  # adds a hint to the move
  def addHint(hint)
    @hints.push(hint);
  end
  
  # adds a hint to the move
  def addHint(key, value)
    self.addHint(DebugHint.new(key, value))
  end
  
  # adds a hint to the move
  def addHint(string)
    self.addHint(DebugHint.new(string))
  end
  
  def ==(another_move)
    return self.x == another_move.x && self.y == another_move.y
  end

  def to_s
    return "Move:(#{self.x},#{self.y})"
  end

end
