# encoding: UTF-8

require 'typesafe_enum'
# All possible field types:
# * WATER
# * BLOCKED
# * PASSENGER0
# * PASSENGER1
# * PASSENGER2
# * PASSENGER3
# * PASSENGER4
# * PASSENGER5
# * SANDBANK
# * LOG
# * GOAL
# Access them with FieldType::WATER.
class FieldType < TypesafeEnum::Base
  new :WATER
  new :BLOCKED
  new :PASSENGER0
  new :PASSENGER1
  new :PASSENGER2
  new :PASSENGER3
  new :PASSENGER4
  new :PASSENGER5
  new :SANDBANK
  new :LOG
  new :GOAL

end
