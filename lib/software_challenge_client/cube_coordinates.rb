class CubeCoordinates

  attr_reader :x, :y, :z

  def initialize(x, y, z = nil)
    @x = x
    @y = y
    @z = z.nil? ? -x - y : z
    throw InvalidArgumentException("sum of coordinates #{@x}, #{@y}, #{@z} have to be equal 0") if @x + @y + @z != 0
  end

end
