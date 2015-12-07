# encoding: UTF-8
# @author Ralf-Tobias Diekert
# A debug hint, that can be added to a move
class DebugHint

  # @!attribute [r] content
  # @return [String] a hint
  attr_reader :content

  # @overload initialize
  #   Creates an empty hint
  # @overload initialize(key, value)
  #   Creates a hint with a key and a value
  #   @param key Key of the hint
  #   @param value of the hint
  # @overload initialize(content)
  #   Creates a hint with specified content
  #   @param content of the hint
  def initialize

  end

  def initialize(key, value)
    if key.nil?
      self.content = "#{value}"
    else
      self.content = "#{key} = #{value}"
    end
  end

  def initialize(content)
    self.content = "#{content}"
  end
end