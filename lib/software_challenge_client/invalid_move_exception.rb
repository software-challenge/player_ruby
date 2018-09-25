# encoding: utf-8

# Exception, die geworfen wird, wenn ein ungültiger Zug ausgeführt wird.
# @see Move#perform!
class InvalidMoveException < StandardError
  def initialize(msg, move)
    @move = move
    super(msg)
  end

  def message
    "#{super}: #{@move}"
  end
end
