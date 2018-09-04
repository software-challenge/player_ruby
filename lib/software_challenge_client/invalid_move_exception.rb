# encoding: UTF-8

# Exception indicating a move which was performed is not valid for the given
# state.
class InvalidMoveException < StandardError
  def initialize(msg, move)
    @move = move
    super(msg)
  end

  def message
    "#{super}: #{@move}"
  end
end
