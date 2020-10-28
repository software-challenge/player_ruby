# frozen_string_literal: true

require 'typesafe_enum'

# Die Spielsteinfarben. BLUE, YELLOW, RED und GREEN
class Color < TypesafeEnum::Base
  new :BLUE, 'B'
  new :YELLOW, 'Y'
  new :RED, 'R'
  new :GREEN, 'G'

  class << self
    def [](digit)
      constants.find { |const| const_get(const) == digit }
    end
  end

  # Gibt den color namen zurück
  def to_s
    self.key.to_s
  end
end
