# encoding: UTF-8
# frozen_string_literal: true
require 'socket'
require_relative 'board'
require_relative 'set_move'
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
    #logger.debug "Parse XML:\n#{text}\n----END XML"
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
    when 'color'
      if @context[:color] == :ordered_colors
        @gamestate.ordered_colors << Color.to_a.find {|s| s.key == @context[:last_text].to_sym }
      end
    when 'shape'
      case @context[:piece_target] 
      when :blue_shapes
        last = @context[:last_text]
        arr = PieceShape.to_a
        shape = arr.find {|s| s.key == @context[:last_text].to_sym }
        @gamestate.undeployed_blue_pieces << shape
      when :yellow_shapes
        shape = PieceShape.to_a.find {|s| s.key == @context[:last_text].to_sym }
        @gamestate.undeployed_yellow_pieces << shape
      when :red_shapes
        shape = PieceShape.to_a.find {|s| s.key == @context[:last_text].to_sym }
        @gamestate.undeployed_red_pieces << shape
      when :green_shapes
        shape = PieceShape.to_a.find {|s| s.key == @context[:last_text].to_sym }
        @gamestate.undeployed_green_pieces << shape
      end
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
      @gamestate.current_color_index = attrs['currentColorIndex'].to_i
      @gamestate.turn = attrs['turn'].to_i
      @gamestate.round = attrs['round'].to_i
      @gamestate.start_piece = PieceShape.to_a.find {|s| s.key == attrs['startPiece'].to_sym }
      logger.debug "Round: #{@gamestate.round}, Turn: #{@gamestate.turn}"
    when 'first'
      logger.debug 'new first player'
      player = Player.new(PlayerType::ONE, attrs['displayName'])
      @gamestate.add_player(player)
      @context[:player] = player
      @context[:color] = :one
    when 'second'
      logger.debug 'new second player'
      player = Player.new(PlayerType::TWO, attrs['displayName'])
      @gamestate.add_player(player)
      @context[:player] = player
      @context[:color] = :two
    when 'orderedColors'
      @context[:color] = :ordered_colors
      @gamestate.ordered_colors = []
    when 'board'
      logger.debug 'new board'
      @gamestate.board = Board.new()
    when 'field'
      x = attrs['x'].to_i
      y = attrs['y'].to_i
      color = Color.find_by_key(attrs['content'].to_sym)
      field = Field.new(x, y, color)
      @gamestate.board.add_field(field)
      @context[:piece_target] = :field
      @context[:field] = field
    when 'blueShapes'
      @context[:piece_target] = :blue_shapes
      @gamestate.undeployed_blue_pieces = []
    when 'yellowShapes'
      @context[:piece_target] = :yellow_shapes
      @gamestate.undeployed_yellow_pieces = []
    when 'redShapes'
      @context[:piece_target] = :red_shapes
      @gamestate.undeployed_red_pieces = []
    when 'greenShapes'
      @context[:piece_target] = :green_shapes
      @gamestate.undeployed_green_pieces = []
    when 'piece'
      color = Color.find_by_key(attrs['color'].to_sym)
      kind = PieceShape.find_by_key(attrs['kind'].to_sym)
      rotation = Rotation.find_by_key(attrs['rotation'].to_sym)
      is_flipped = attrs['isFlipped'].downcase == "true"
      piece = Piece.new(color, kind, rotation, is_flipped, Coordinates.origin)
      case @context[:piece_target]
      when :blue_shapes
        @gamestate.undeployed_blue_pieces << piece
      when :yellow_shapes
        @gamestate.undeployed_yellow_pieces << piece
      when :red_shapes 
        @gamestate.green_red_pieces << piece
      when :green_shapes
        @gamestate.undeployed_green_pieces << piece
      when :last_move
        @context[:last_move_piece] = piece
      else
        raise "unknown piece target #{@context[:piece_target]}"
      end
    when 'lastMove'
      type = attrs['class']
      if type == 'skipmove'
        @gamestate.last_move = SkipMove.new
      else
        @context[:last_move_type] = type
        @context[:piece_target] = :last_move
      end
    when 'position'
      case @context[:piece_target] 
      when :last_move
        x = attrs['x'].to_i
        y = attrs['y'].to_i
        piece = @context[:last_move_piece]
        @gamestate.last_move = SetMove.new(Piece.new(piece.color, piece.kind, piece.rotation, piece.is_flipped, Coordinates.new(x, y)))
      end
    when 'startColor'
      @gamestate.start_color = Color::BLUE
    when 'winner'
      # TODO
      # winning_player = parsePlayer(attrs)
      # @gamestate.condition = Condition.new(winning_player, @gamestate.condition.reason)
    when 'score'
      # TODO
      # there are two score tags in the result, but reason attribute should be equal on both
      # @gamestate.condition = Condition.new(@gamestate.condition.winner, attrs['reason'])
    when 'left'
      logger.debug 'got left event, terminating'
      @network.disconnect
    when 'sc.protocol.responses.CloseConnection'
      logger.debug 'got left close connection event, terminating'
      @network.disconnect
    end
  end

  # send a xml document
  #
  # @param document [REXML::Document] the document, that will be send to the connected server
  def sendXml(document)
    @network.sendXML(document)
  end

  # send a string
  #
  # @param string [String] The string that will be send to the connected server.
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
      builder.data(class: 'sc.plugin2021.SetMove') do |data|
        data.piece(color: move.piece.color, kind: move.piece.kind, rotation: move.piece.rotation, isFlipped: move.piece.is_flipped) do |piece|
          piece.position(x: move.piece.position.x, y: move.piece.position.y)
        end
        move.hints.each do |hint|
          data.hint(content: hint.content)
        end
      end
    when SkipMove
      builder.data(class: 'sc.plugin2021.SkipMove') do |data|
        data.color(@gamestate.current_color.key.to_s)
        move.hints.each do |hint|
          data.hint(content: hint.content)
        end
      end
    end
    builder.target!
  end
end
