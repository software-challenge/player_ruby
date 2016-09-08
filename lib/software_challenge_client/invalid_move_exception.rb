# encoding: UTF-8
class InvalidMoveException < StandardError
  def initialize(msg, move)
    @move = move
    super(msg)
  end

  def message
    "#{super}: #{@move}"
  end
end
