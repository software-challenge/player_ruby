# To change this license header, choose License Headers in Project Properties.
# To change this template file, choose Tools | Templates
# and open the template in the editor.

class DebugHint
  attr_reader :content
  
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
