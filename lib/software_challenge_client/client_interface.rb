# encoding: UTF-8

# The interface a client should implement to work with the gem.
class ClientInterface
  # Is updated by the gem, when a new gamestate is received from the server.
  attr_accessor :gamestate

  # Is called when the server requests a move from the client.
  # @return [Move] Needs to return a valid move.
  def move_requested
    raise 'Not yet implemented'
  end
end
