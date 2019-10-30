class SetMove

  attr_reader :piece
  attr_reader :destination

  def initialize(piece, destination)
    @piece = piece
    @destination = destination
  end
end
