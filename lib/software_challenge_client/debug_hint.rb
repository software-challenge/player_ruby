# encoding: UTF-8
# A debug hint, that can be added to a move
class DebugHint
  # @!attribute [r] content
  # @return [String] a hint
  attr_reader :content

  # @param content of the hint, will be converted to a string
  def initialize(content)
    @content = content.to_s
  end
end
