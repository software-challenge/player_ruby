# coding: utf-8
# frozen_string_literal: true
require 'logger'

# Dieses Modul kann inkludiert werden, um eine Logausgabe auf der Konsole verwenden zu können.
# See http://stackoverflow.com/a/6768164/390808
#
# Verwendung:
#
#   class MyClass
#     include Logging
#
#     def a_method(x)
#       logger.debug "you provided #{x}"
#     end
#   end
module Logging
  def logger
    Logging.logger
  end

  # Global, memoized, lazy initialized instance of a logger
  def self.logger
    @logger ||= Logger.new(STDOUT)
  end
end
