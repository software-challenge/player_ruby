# This module provides a shared logger to all classes into which it is mixed.
# See http://stackoverflow.com/a/6768164/390808
#
# Usage:
#
# class MyClass
#   include Logging
#
#   def a_method(x)
#     logger.debug "you provided #{x}"
#   end
# end
require 'logger'

module Logging
  def logger
    Logging.logger
  end

  # Global, memoized, lazy initialized instance of a logger
  def self.logger
    @logger ||= Logger.new(STDOUT)
  end
end
