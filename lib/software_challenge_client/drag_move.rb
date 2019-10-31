class DragMove

  attr_reader :start
  attr_reader :destination

  def initialize(start, destination)
    @start = start
    @destination = destination
  end

  def to_s
    "[Move: Drag from #{start} to #{destination}]"
  end
end
