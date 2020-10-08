# frozen_string_literal: true

require_relative 'has_hints'

# Ein SkipMove ziegt an, dass die aktuelle Farbe keinen Stein platzieren will
class SkipMove
  include HasHints

  def initialize
    @hints = []
  end
end
