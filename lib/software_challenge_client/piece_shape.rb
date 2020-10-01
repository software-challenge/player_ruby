# frozen_string_literal: true

require 'typesafe_enum'
# Die Form eines Spielsteins. Es gibt folgende Formen:
#
#   MONO
#   DOMINO
#   TRIO_L
#   TRIO_I
#   TETRO_O
#   TETRO_T
#   TETRO_I
#   TETRO_L
#   TETRO_Z
#   PENTO_L
#   PENTO_T
#   PENTO_V
#   PENTO_S
#   PENTO_Z
#   PENTO_I
#   PENTO_P
#   PENTO_W
#   PENTO_U
#   PENTO_R
#   PENTO_X
#   PENTO_Y
#
# Zugriff z.B. mit PieceShape::PENTO_S
class PieceShape < TypesafeEnum::Base
  new :MONO, [Coordinates(0, 0)]
  new :DOMINO, [Coordinates(0, 0), Coordinates(1, 0)]
  new :TRIO_L, [Coordinates(0, 0), Coordinates(0, 1), Coordinates(1, 1)]
  new :TRIO_I, [Coordinates(0, 0), Coordinates(0, 1), Coordinates(0, 2)]
  new :TETRO_O, [Coordinates(0, 0), Coordinates(1, 0), Coordinates(0, 1), Coordinates(1, 1)]
  new :TETRO_T, [Coordinates(0, 0), Coordinates(1, 0), Coordinates(2, 0), Coordinates(1, 1)]
  new :TETRO_I, [Coordinates(0, 0), Coordinates(0, 1), Coordinates(0, 2), Coordinates(0, 3)]
  new :TETRO_L, [Coordinates(0, 0), Coordinates(0, 1), Coordinates(0, 2), Coordinates(1, 2)]
  new :TETRO_Z, [Coordinates(0, 0), Coordinates(1, 0), Coordinates(1, 1), Coordinates(2, 1)]
  new :PENTO_L, [Coordinates(0, 0), Coordinates(0, 1), Coordinates(0, 2), Coordinates(0, 3), Coordinates(1, 3)]
  new :PENTO_T, [Coordinates(0, 0), Coordinates(1, 0), Coordinates(2, 0), Coordinates(1, 1), Coordinates(1, 2)]
  new :PENTO_V, [Coordinates(0, 0), Coordinates(0, 1), Coordinates(0, 2), Coordinates(1, 2), Coordinates(2, 2)]
  new :PENTO_S, [Coordinates(1, 0), Coordinates(2, 0), Coordinates(3, 0), Coordinates(0, 1), Coordinates(1, 1)]
  new :PENTO_Z, [Coordinates(0, 0), Coordinates(1, 0), Coordinates(1, 1), Coordinates(1, 2), Coordinates(2, 2)]
  new :PENTO_I, [Coordinates(0, 0), Coordinates(0, 1), Coordinates(0, 2), Coordinates(0, 3), Coordinates(0, 4)]
  new :PENTO_P, [Coordinates(0, 0), Coordinates(1, 0), Coordinates(0, 1), Coordinates(1, 1), Coordinates(0, 2)]
  new :PENTO_W, [Coordinates(0, 0), Coordinates(0, 1), Coordinates(1, 1), Coordinates(1, 2), Coordinates(2, 2)]
  new :PENTO_U, [Coordinates(0, 0), Coordinates(0, 1), Coordinates(1, 1), Coordinates(2, 1), Coordinates(2, 0)]
  new :PENTO_R, [Coordinates(0, 1), Coordinates(1, 1), Coordinates(1, 2), Coordinates(2, 1), Coordinates(2, 0)]
  new :PENTO_X, [Coordinates(1, 0), Coordinates(0, 1), Coordinates(1, 1), Coordinates(2, 1), Coordinates(1, 2)]
  new :PENTO_Y, [Coordinates(0, 1), Coordinates(1, 0), Coordinates(1, 1), Coordinates(1, 2), Coordinates(1, 3)]
end
