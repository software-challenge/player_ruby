# encoding: UTF-8
require_relative 'board'
require_relative 'client_interface'
require_relative 'network'

class Runner
  include Logging

  attr_reader :network

  def initialize(host, port, client, reservation = nil)
    logger.info 'Software Challenge 2017'
    logger.info 'Ruby Client'
    logger.info "Host: #{host}"
    logger.info "Port: #{port}"

    board = Board.new(true)
    @network = Network.new(host, port, board, client, reservation)
  end

  def start
    self.network.connect
    if self.network.connected == false
      logger.error 'Not connected'
      return
    end

    while self.network.connected
      self.network.processMessages
      sleep(0.01)
    end

    logger.info 'Program end...'
    self.network.disconnect
  end
end
