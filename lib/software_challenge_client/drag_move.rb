require_relative 'has_hints'

# Ein Zug, der einen auf dem Spielbrett befindlichen Spielstein bewegt.
class DragMove

  include HasHints

  attr_reader :start
  attr_reader :destination

  # @param start [CubeCoordinates]
  # @param destination [CubeCoordinates]
  def initialize(start, destination)
    @start = start
    @destination = destination
    @hints = []
  end

  def to_s
    "[Move: Drag from #{start} to #{destination}]"
  end
end
