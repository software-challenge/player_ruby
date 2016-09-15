# encoding: UTF-8
class FieldUnavailableException < StandardError
  attr_reader :x, :y

  def initialize(x, y)
    # This exception will be thrown if a field is accessed which is not
    # available.
    super("Field with coordinates (#{x},#{y}) is not available.")
    @x = x
    @y = y
  end
end
