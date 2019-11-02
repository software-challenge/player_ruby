require_relative 'has_hints'

class SetMove

  include HasHints

  attr_reader :piece
  attr_reader :destination

  def initialize(piece, destination)
    @piece = piece
    @destination = destination
    @hints = []
  end
end
