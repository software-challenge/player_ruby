# encoding: UTF-8
# Exception indicating that a requested field does not exist.
class FieldUnavailableException < StandardError
  # @!attribute [r] x
  # @return [Integer] the X-coordinate of the requested field.
  attr_reader :x

  # @!attribute [r] y
  # @return [Integer] the Y-coordinate of the requested field.
  attr_reader :y

  def initialize(x, y)
    super("Field with coordinates (#{x},#{y}) is not available.")
    @x = x
    @y = y
  end
end
