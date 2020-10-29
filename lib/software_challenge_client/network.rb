# encoding: UTF-8
# frozen_string_literal: true

require 'socket'
require 'rexml/document'
require 'rexml/element'

require_relative 'protocol'
require_relative 'board'
require_relative 'client_interface'
require_relative 'util/constants'

# This class handles the socket connection to the server
class Network
  include Logging
  include Constants

  # @!attribute [r] connected
  # @return [Boolean] true, if the client is connected to a server
  attr_reader :connected

  def initialize(host, port, board, client, reservation = nil)
    @host = host
    @port = port
    @board = board
    @client = client

    @connected = false
    @protocol = Protocol.new(self, @client)
    @reservation_id = reservation || ''
    @receive_buffer = ''
  end

  # connects the client with a given server
  #
  # @return [Boolean] true, if successfully connected to the server
  def connect
    @socket = TCPSocket.open(@host, @port)
    logger.info 'Connection to server established.'
    @connected = true

    sendString('<protocol>')
    document = REXML::Document.new
    if @reservation_id != ''
      element = REXML::Element.new('joinPrepared')
      element.add_attribute('reservationCode', @reservation_id)
    else
      element = REXML::Element.new('join')
      element.add_attribute('gameType', GAME_IDENTIFIER)
    end
    document.add(element)
    sendXML(document)
    @connected
  end

  # disconnects the client from a server
  def disconnect
    if @connected
      sendString('</protocol>')
      @connected = false
      @socket.close
    end
    logger.info 'Connection to server closed.'
  end

  # reads from the socket until "</room>" is read
  def readString
    return false unless @connected
    sock_msg = ''

    line = ''
    @socket.each_char do |char|
      line += char
      sock_msg += char
      line = '' if ['\n', ' '].include? char
      break if ['</room>', '</protocol>'].include? line
    end
    if sock_msg != ''
      @receive_buffer.concat(sock_msg)

      # Remove <protocol> tag
      @receive_buffer = @receive_buffer.gsub('<protocol>', '')
      @receive_buffer = @receive_buffer.gsub('</protocol>', '')

      logger.debug "Received XML from server: #{@receive_buffer}"

      # Process text
      @protocol.process_string(@receive_buffer)
      emptyReceiveBuffer
    end
    true
  end

  # sends a xml Document to the buffer
  #
  # @param xml [REXML::Document] the Document, that will be sent
  def sendXML(xml)
    text = ''.dup
    xml.write(text)
    sendString(text)
  end

  # processes an incomming message
  #
  # @return [Boolean] true, if the processing of a incomming message was successfull
  def processMessages
    return false unless @connected
    readString
  end

  # sends a string to the socket
  #
  # @param s [String] the message, to be sent
  def sendString(s)
    return unless @connected
    logger.debug "Sending: #{s}"
    @socket.print(s)
  end

  private

  # empties the receive buffer
  def emptyReceiveBuffer
    @receive_buffer = ''
  end
end
