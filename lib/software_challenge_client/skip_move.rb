# frozen_string_literal: true
require_relative 'has_hints'
class SkipMove
  include HasHints

  def initialize
    @hints = []
  end
end
