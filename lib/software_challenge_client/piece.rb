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

  def to_s
    color.value + type.value
  end
end
