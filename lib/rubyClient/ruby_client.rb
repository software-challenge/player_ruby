require_relative 'board'
require_relative 'client_interface'
require_relative 'network'

class RubyClient
  attr_reader :network

  def initialize(host, port, client)
    puts 'Software Challenge 2015'
    puts 'Ruby Client'
    puts "Host: #{host}"
    puts "Port: #{port}"
    
    board = Board.new(true)
    @network = Network.new(host, port, board, client)    
  end

  def start
    self.network.connect
    if self.network.connected == false
      puts 'Not connected'
      return
    end

    while self.network.connected
      self.network.processMessages
      sleep(0.01)
    end

    puts 'Program end...'
    self.network.disconnect  
  end
end
