# To change this license header, choose License Headers in Project Properties.
# To change this template file, choose Tools | Templates
# and open the template in the editor.

require 'socket'
require_relative 'protocol'
require_relative 'board'
require_relative 'simpleClient/client'
require 'rexml/document'
require 'rexml/element'

class Network
  @socket
  @host
  @port
    
  @board
  @client
  @protocol
    
  @receiveBuffer
  @reservationID

  attr_reader :connected
    
  def initialize(host, port, board, client)
    @host, @port, @connected, @board, @client = 
      host, port, false, board, client
  
    @protocol = Protocol.new(self, @board, @client)
    @reservationID = ''
  @receiveBuffer = ''
  
    puts '> Network/Socket created.'
  end
  
  def connect
    @socket = TCPSocket.open(@host, @port)
    @connected = true
  
    self.sendString('<protocol>')
    if @reservationID != ''
      document = REXML::Docuent.new
      element = REXML::Element.new('joinPrepared')
      element.add_attribute('reservationCode', @reservationID)
      document.add(element)
      self.sendXML(document)
    else 
      document = REXML::Document.new
      element = REXML::Element.new('join')
      element.add_attribute('gameType', 'swc_2016_twixt')
      document.add(element)
      self.sendXML(document)
    end
    @connected
  end
  
  def disconnect

    if @connected
        sendString("</protocol>")
        @connected = false
      @socket.close
    end
    puts '> Disconnected.'
  end

  def readString
    puts 'reading'
    sockMsg = ''
  #  if(!@connected) 
  #    return
  #  end
  
    line =''
    char = ''
    while line!="</room>"
      char = @socket.getc
      line+=char
      if char=='\n' || char==' '

        line = ''
      end
    sockMsg += char
    end
    puts 'ended reading'
    #puts '.'
    #sockMsg = @socket.read
    #puts '..'
    if sockMsg != ''
    
      @receiveBuffer.concat(sockMsg)

      # Remove <protocol> tag
      @receiveBuffer = @receiveBuffer.gsub('<protocol>', '')

      puts 'Receive:'
      puts ''
      #puts @receiveBuffer
    
      #// Process text
      @protocol.processString('<msg>'+@receiveBuffer+'</msg>');
      self.emptyReceiveBuffer
    end
    true
  end

  def emptyReceiveBuffer
    @receiveBuffer = ''
  end

  def processMessages
    if !@connected
      return false
    end

    self.readString
  end

  def sendString(s)
    if(@connected)
      @socket.print(s);
      puts 'Send:'
      puts ''
      puts(s);
    end
  end

  def sendXML(xml)
    text  = ''
    xml.write(text)
    self.sendString(text);
  end

end
