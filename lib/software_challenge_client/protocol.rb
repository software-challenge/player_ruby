# encoding: UTF-8
# frozen_string_literal: true
require 'socket'
require_relative 'board'
require_relative 'set_move'
require_relative 'drag_move'
require_relative 'skip_move'
require_relative 'player'
require_relative 'network'
require_relative 'client_interface'
require 'rexml/document'
require 'rexml/streamlistener'
require 'builder'

# This class handles communication to the server over the XML communication
# protocol. Messages from the server are parsed and moves are serialized and
# send back.
class Protocol
  include Logging
  include REXML::StreamListener

  # @!attribute [r] gamestate
  # @return [Gamestate] current gamestate
  attr_reader :gamestate
  # @!attribute [rw] roomId
  # @return [String] current room id
  attr_accessor :roomId
  # @!attribute [r] client
  # @return [ClientInterface] current client
  attr_reader :client

  def initialize(network, client)
    @gamestate = GameState.new
    @network = network
    @client = client
    @context = {} # for saving context when stream-parsing the XML
    @client.gamestate = @gamestate
  end

  # starts xml-string parsing
  #
  # @param text [String] the xml-string that will be parsed
  def process_string(text)
    logger.debug "Parse XML:\n#{text}\n----END XML"
    begin
      REXML::Document.parse_stream(text, self)
    rescue REXML::ParseException => e
      # to parse incomplete xml, ignore missing end tag exceptions
      raise e unless e.message =~ /Missing end tag/
    end
  end


  # called when text is encountered
  def text(text)
    @context[:last_text] = text
  end

  # called if an end-tag is read
  #
  # @param name [String] the end-tag name, that was read
  def tag_end(name)
    case name
    when 'board'
      logger.debug @gamestate.board.to_s
    end
  end

  # called if a start tag is read
  # Depending on the tag the gamestate is updated
  # or the client will be asked for a move
  #
  # @param name [String] the start-tag, that was read
  # @param attrs [Dictionary<String, String>] Attributes attached to the tag
  def tag_start(name, attrs)
    case name
    when 'room'
      @roomId = attrs['roomId']
      logger.info 'roomId : ' + @roomId
    when 'data'
      logger.debug "data(class) : #{attrs['class']}"
      @context[:data_class] = attrs['class']
      if attrs['class'] == 'sc.framework.plugins.protocol.MoveRequest'
        @client.gamestate = gamestate
        move = @client.move_requested
        sendString(move_to_xml(move))
      end
      if attrs['class'] == 'error'
        logger.info "Game ended - ERROR: #{attrs['message']}"
        @network.disconnect
      end
      if attrs['class'] == 'result'
        logger.info 'Got game result'
        @network.disconnect
        @gamestate.condition = Condition.new(nil, '')
      end
    when 'state'
      logger.debug 'new gamestate'
      @gamestate = GameState.new
      @gamestate.turn = attrs['turn'].to_i
      @gamestate.start_player_color = attrs['startPlayerColor'] == 'RED' ? PlayerColor::RED : PlayerColor::BLUE
      @gamestate.current_player_color = attrs['currentPlayerColor'] == 'RED' ? PlayerColor::RED : PlayerColor::BLUE
      logger.debug "Turn: #{@gamestate.turn}"
    when 'red'
      logger.debug 'new red player'
      player = parsePlayer(attrs)
      if player.color != PlayerColor::RED
        throw new IllegalArgumentException("expected #{PlayerColor::RED} Player but got #{player.color}")
      end
      @gamestate.add_player(player)
      @context[:player] = player
    when 'blue'
      logger.debug 'new blue player'
      player = parsePlayer(attrs)
      if player.color != PlayerColor::BLUE
        throw new IllegalArgumentException("expected #{PlayerColor::BLUE} Player but got #{player.color}")
      end
      @gamestate.add_player(player)
      @context[:player] = player
    when 'board'
      logger.debug 'new board'
      @gamestate.board = Board.new
    when 'field'
      x = attrs['x'].to_i
      y = attrs['y'].to_i
      obstructed = attrs['isObstructed'] == 'true'
      field = Field.new(x, y, [], obstructed)
      @gamestate.board.add_field(field)
      @context[:field] = field
    when 'piece'
      owner = PlayerColor.find_by_key(attrs['owner'].to_sym)
      type = PieceType.find_by_key(attrs['type'].to_sym)
      @context[:field].add_piece(Piece.new(owner, type))
    when 'lastMove'
      # TODO
      #@gamestate.last_move = move
    when 'winner'
    # TODO
      #winning_player = parsePlayer(attrs)
      #@gamestate.condition = Condition.new(winning_player, @gamestate.condition.reason)
    when 'score'
      # TODO
      # there are two score tags in the result, but reason attribute should be equal on both
      #@gamestate.condition = Condition.new(@gamestate.condition.winner, attrs['reason'])
    when 'left'
      logger.debug 'got left event, terminating'
      @network.disconnect
    when 'sc.protocol.responses.CloseConnection'
      logger.debug 'got left close connection event, terminating'
      @network.disconnect
    end
  end

  # Converts XML attributes for a Player to a new Player object
  #
  # @param attributes [Hash] Attributes for the new Player.
  # @return [Player] The created Player object.
  def parsePlayer(attributes)
    Player.new(
      PlayerColor.find_by_key(attributes['color'].to_sym),
      attributes['displayName']
    )
  end

  # send a xml document
  #
  # @param document [REXML::Document] the document, that will be send to the connected server
  def sendXml(document)
    @network.sendXML(document)
  end

  # send a string
  #
  # @param document [String] The string that will be send to the connected server.
  def sendString(string)
    @network.sendString("<room roomId=\"#{@roomId}\">#{string}</room>")
  end

  # converts "this_snake_case" to "thisSnakeCase"
  def snake_case_to_lower_camel_case(string)
    string.split('_').inject([]) do |result, e|
      result + [result.empty? ? e : e.capitalize]
    end.join
  end

  # Converts a move to XML for sending to the server.
  #
  # @param move [Move] The move to convert to XML.
  def move_to_xml(move)
    builder = Builder::XmlMarkup.new(indent: 2)
    # Converting every the move here instead of requiring the Move
    # class interface to supply a method which returns the XML
    # because XML-generation should be decoupled from internal data
    # structures.
    case move
    when SetMove
      builder.data(class: 'setmove') do |data|
        data.piece(owner: move.piece.owner.key, type: move.piece.type.key)
        d = move.destination
        data.destination(x: d.x, y: d.y, z: d.z)
        move.hints.each do |hint|
          data.hint(content: hint.content)
        end
      end
    when DragMove
      builder.data(class: 'dragmove') do |data|
        s = move.start
        data.start(x: s.x, y: s.y, z: s.z)
        d = move.destination
        data.destination(x: d.x, y: d.y, z: d.z)
        move.hints.each do |hint|
          data.hint(content: hint.content)
        end
      end
    when SkipMove
      builder.data(class: 'skipmove') do |data|
        move.hints.each do |hint|
          data.hint(content: hint.content)
        end
      end
    end
    builder.target!
  end

end
