# frozen_string_literal: true

require_relative 'has_hints'

# Ein SkipMove ziegt an, dass die aktuelle Farbe keinen Stein platzieren will
class SkipMove
  include HasHints

  # Erstellt ein neuen leeren Aussetzzug.
  def initialize
    @hints = []
  end
end
