# frozen_string_literal: true
class Piece
  # @!attribute [r] type
  # @return [PieceType]
  attr_reader :type

  # @!attribute [r] color
  # @return [PlayerColor]
  attr_reader :color

  def initialize(color, type)
    @type = type
    @color = color
  end

  def ==(other)
    type == other.type && color == other.color
  end

  def owner
    color
  end

  def to_s
    color.value + type.value
  end

  def inspect
    to_s
  end
end
