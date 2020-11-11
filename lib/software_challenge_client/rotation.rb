# frozen_string_literal: true

require 'typesafe_enum'

# Die Drehung eines Steins
class Rotation < TypesafeEnum::Base
  new :NONE, 0
  new :RIGHT, 1
  new :MIRROR, 2
  new :LEFT, 3

  # Summiere beide Rotationen auf.
  # (Die resultierende Rotation hat den gleichen Effekt wie die beiden Rotationen einzeln).
  def rotate(rotation)
    Rotation.to_a[(value + rotation.value) % Rotation.size]
  end

  # Gibt den rotation namen zurück
  def to_s
    self.key.to_s
  end
end
