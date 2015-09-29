# encoding: UTF-8
require 'socket'
require_relative 'protocol'
require_relative 'board'
require_relative 'client_interface'
require 'rexml/document'
require 'rexml/element'

# @author Ralf-Tobias Diekert
# This class handles the socket connection to the server
class Network
  @socket
  @host
  @port
    
  @board
  @client
  @protocol
    
  @receiveBuffer
  @reservationID
  
  # @!attribute [r] connected
  # @return [Boolean] true, if the client is connected to a server
  attr_reader :connected
    
  def initialize(host, port, board, client)
    @host, @port, @connected, @board, @client = 
      host, port, false, board, client
  
    @protocol = Protocol.new(self, @client)
    @reservationID = ''
    @receiveBuffer = ''
  
    puts '> Network/Socket created.'
  end

  # connects the client with a given server
  # 
  # @return [Boolean] true, if successfully connected to the server
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
    return @connected
  end
  
  # disconnects the client from a server
  def disconnect

    if @connected
      sendString("</protocol>")
      @connected = false
      @socket.close
    end
    puts '> Disconnected.'
  end

  # reads from the socket until "</room>" is read
  def readString
    puts 'reading'
    sockMsg = ''
    if(!@connected) 
      return
    end
  
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
    if sockMsg != ''
    
      @receiveBuffer.concat(sockMsg)

      # Remove <protocol> tag
      @receiveBuffer = @receiveBuffer.gsub('<protocol>', '')

      puts 'Receive:'
      puts ''
      #puts @receiveBuffer
    
      # Process text
      @protocol.processString('<msg>'+@receiveBuffer+'</msg>');
      self.emptyReceiveBuffer
    end
    return true
  end

  # empties the receive buffer
  def emptyReceiveBuffer
    @receiveBuffer = ''
  end

  # processes an incomming message
  #
  # @return [Boolean] true, if the processing of a incomming message was successfull
  def processMessages
    if !@connected
      return false
    end
    return self.readString
  end

  # sends a string to the socket
  #
  # @param s [String] the message, to be sent
  def sendString(s)
    if(@connected)
      @socket.print(s);
      puts 'Send:'
      puts ''
      puts(s);
    end
  end

  # sends a xml Document to the buffer
  #
  # @param xml [REXML::Docuent] the Document, that will be sent
  def sendXML(xml)
    text  = ''
    xml.write(text)
    self.sendString(text);
  end

end