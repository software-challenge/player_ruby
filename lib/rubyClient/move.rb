require_relative 'debug_hint'

# @author Ralf-Tobias Diekert
# A move, that can be performed in twixt
class Move
  # @!attribute [r] x
  # @return [Integer] x-coordinate
  attr_reader :x
  # @!attribute [r] y
  # @return [Integer] y-coordinate
  attr_reader :y
  # @!attribute [r] hints
  # @return [Array<DebugHint>] the move's hints
  attr_reader :hints
  
  # Initializer
  # 
  # @param x [Integer] x-coordinate
  # @param y [Integer] y-coordinate
  def initialize(x, y)
    @x = x
    @y = y
    @hints = Array.new
  end
  
  # @overload addHint(hint)
  # adds a hint to the move
  # @param hint [DebugHint] the added hint
  # @overload addHint(key, value)
  # adds a hint to the move
  # @param key the added hint's key
  # @param value the added hint's value
  # @overload addHint(string)
  # adds a hint to the move
  # @param hint [String] the added hint's content
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
