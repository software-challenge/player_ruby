# frozen_string_literal: true

require 'typesafe_enum'

# TODO 2022: Replace with bool?
# Die Spielsteinfarben. BLUE, und RED
class Color < TypesafeEnum::Base
  new :BLUE, 'B'
  new :RED, 'R'

  # Gibt den color namen zurück
  def to_s
    self.key.to_s
  end
end
