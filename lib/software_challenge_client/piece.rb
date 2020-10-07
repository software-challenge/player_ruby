# frozen_string_literal: true
class Piece
  # @!attribute [r] type
  # @return [PieceShape]
  attr_reader :shape

  # @!attribute [r] color
  # @return [PlayerColor]
  attr_reader :color

  def initialize(color, shape)
    @type = shape
    @color = color
  end

  def ==(other)
    shape == other.shape && color == other.color
  end

  def owner
    color
  end

  def to_s
    color.value + shape.value
  end

  def inspect
    to_s
  end
end
