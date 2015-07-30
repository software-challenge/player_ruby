# To change this license header, choose License Headers in Project Properties.
# To change this template file, choose Tools | Templates
# and open the template in the editor.

require_relative '../board'
require_relative 'client'
require_relative '../network'

host = '127.0.0.1'
if host == 'localhost' then host = '127.0.0.1' end
port = 13050
    
puts 'Software Challenge 2015'
puts 'Ruby Client'
puts "Host: #{host}"
puts "Port: #{port}"
    
    
client = Client.new
board = Board.new(true)
network = Network.new(host, port, board, client)    
network.connect
if network.connected == false
  puts 'Not connected'
  return
end

while network.connected
    network.processMessages
 sleep(0.01)
end

puts 'Program end...'
network.disconnect  
 
