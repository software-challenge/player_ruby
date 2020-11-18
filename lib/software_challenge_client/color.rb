# frozen_string_literal: true

require 'typesafe_enum'

# Die Spielsteinfarben. BLUE, YELLOW, RED und GREEN
class Color < TypesafeEnum::Base
  new :BLUE, 'B'
  new :YELLOW, 'Y'
  new :RED, 'R'
  new :GREEN, 'G'

  # Gibt den color namen zurück
  def to_s
    self.key.to_s
  end
end
