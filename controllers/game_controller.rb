require './models/game_grid_model.rb'
require './models/game_piece_model.rb'
require './models/grid_point_model.rb'
require './models/player_model.rb'
require './views/game_grid_view.rb'


class GameController

  STATE_START_TURN = 0
  STATE_SELECT_PIECE = 1
  STATE_MOVE_PIECE = 2
  STATE_END_TURN = 3

  def initialize

    # -- Setup game grid.
    @game_grid_model = GameGridModel.new
    game_grid_x_size = 7
    game_grid_y_size = 7
    @game_grid_model.set_size(game_grid_x_size, game_grid_y_size)
    @game_grid_view = GameGridView.new(@game_grid_model)

    # -- Setup players.
    @players = { 1 => PlayerModel.new(1, :X), 2 => PlayerModel.new(2, :O) }
    @player_piece_design_lookup = { 1 => :X, 2 => :O, 3 => :Y, 4 => :P}
    @current_player = nil
    @current_player_id = nil
    @current_player_piece = nil

    # -- Setup player pieces
    add_new_player_piece(1, GridPointModel.new(0, 0))
    add_new_player_piece(1, GridPointModel.new(game_grid_x_size-1, game_grid_y_size-1))
    add_new_player_piece(2, GridPointModel.new(game_grid_y_size-1, 0))
    add_new_player_piece(2, GridPointModel.new(0, game_grid_y_size-1))


    # @game_grid_model.unoccupied_locations.each do |location|
    #   add_new_player_piece(1, location)
    # end

    # remove_player_piece(@game_grid_model.get_game_piece("g6"))

  end

  def start
    # -- Initialize start of game.
    @game_state = STATE_START_TURN

    player_order = [1, 2]
    player_position = 0
    message = nil
    @game_running = true

    # -- Run game loop.
    while(@game_running) do

      case @game_state
      # -- Start of player turn.
      when STATE_START_TURN
        # -- Select next player.
        @current_player_id = player_order[player_position]
        @current_player = @players[@current_player_id]

        # -- Set status message.
        message = nil
        # -- Transition to next game state.
        @game_state = STATE_SELECT_PIECE

      when STATE_SELECT_PIECE
        # -- Draw game board and message.
        redraw_board(message)

        # -- Get player selection.
        print "Move which piece?: "
        piece_location = gets.strip

        # -- Attempt to get player piece at that location.
        @current_player_piece = get_player_piece(@current_player_id, piece_location)


        if @current_player_piece == nil
          # -- Invalid piece selection.
          message = "\"#{piece_location}\" is not a valid selection."
        else
          # -- Valid piece selection.
          # -- Update game grid with possible moves for selected piece.
          @game_grid_model.set_target_locations(@current_player_piece.available_moves)
          # -- Set status message.
          message = nil
          # -- Transition to next game state.
          @game_state = STATE_MOVE_PIECE
        end


      when STATE_MOVE_PIECE
        # -- Draw game board and message.
        redraw_board(message)

        # -- Get player move.
        print "Move \"#{piece_location}\" to where?: "
        piece_destintation = gets.strip

        if @current_player_piece.allowed_move?(piece_destintation) &&
          !@game_grid_model.occupied_location?(piece_destintation)
          # -- Move is allowed by piece and destination is not occupied.

          # -- Get destination grid point.
          piece_destination_grid_point = @game_grid_model.get_location_grid_point(piece_destintation)

          if (@current_player_piece.location_grid_point.x - piece_destination_grid_point.x).abs > 1 ||
            (@current_player_piece.location_grid_point.y - piece_destination_grid_point.y).abs > 1
            # -- Movement is more than one space.

            # -- Piece jumps instead of duplicating.
            remove_player_piece(@current_player_piece)
          end

          # -- Add new piece.
          @attacking_player_piece = add_new_player_piece(@current_player_id, piece_destintation)
          # -- Assmiilate adjacent opponent pieces.
          assimilate_adjacent_enemies(@attacking_player_piece)

          # -- Clear possible moves from game grid.
          @game_grid_model.set_target_locations(nil)

          # -- Set status message.
          message = nil
          # -- Transition to next game state.
          @game_state = STATE_END_TURN
        else
          # -- Move is not allowed by piece or destination is occupied.

          if piece_destintation.empty?
            # -- No destination entered.

            # -- Clear possible moves from game grid.
            @game_grid_model.set_target_locations(nil)

            # -- Set status message.
            message = "Deselected \"#{piece_location}\"."
            # -- Transition to previous game state.
            @game_state = STATE_SELECT_PIECE
          else
            # -- Invalid destination entered.
            message = "\"#{piece_destintation}\" is not a valid move."
          end
        end
      when STATE_END_TURN

        if has_game_ended?
          # -- Game has ended.

          @game_running = false

          # -- Draw final board.
          redraw_board(message)

          # -- Handle winner or draw.
          if @winner == nil
            puts "Result: The game is a draw."
          else
            puts "Result: Player #{@winner.logo} wins!"
          end
          puts "GAME OVER"

        else
          # -- Game still running.

          # -- Switch to next player.
          player_position += 1
          player_position = player_position >= player_order.length ? 0 : player_position

          # puts "Press enter for next turn..."
          # gets


          # -- Set status message.
          message = nil
          # -- Transition to next game state.
          @game_state = STATE_START_TURN
        end
      end



    end


  end

  def has_game_ended?

    # -- Find all players that still have pieces.
    players_with_pieces = []
    @players.each do |player_id, player|

      if player.has_pieces?
        players_with_pieces.push(player)
      end

    end


    if players_with_pieces.length == 1
      # -- Only one player has pieces.

      # -- Set winner and indicate game end.
      @winner = players_with_pieces[0]
      return true
    end


    # -- Find all players that still have moves.
    players_with_moves = []
    @players.each do |player_id, player|

      if player.has_moves?
        players_with_moves.push(player)
      end

    end

    if players_with_moves.length == 1
      # -- Only one player has moves.

      # -- Fill rest of board with this player's pieces
      @game_grid_model.unoccupied_locations.each do |location|
        player_id = players_with_moves[0].player_id
        add_new_player_piece(player_id, location)
      end
      # -- Update that no players have moves.
      players_with_moves.clear
    end

    if players_with_moves.length == 0
      # -- No players have moves.

      # -- Determine which player has the most pieces.
      most_pieces = 0
      players_with_most = []
      @players.each do |player_id, player|
        # puts "#{player_id} : #{player.get_piece_count}"
        if player.get_piece_count >= most_pieces
          if player.get_piece_count > most_pieces
            players_with_most.clear
          end
          players_with_most.push(player)
          most_pieces = player.get_piece_count
          # puts "ADDING PLAYER"
        end
      end

      if players_with_most.length == 1
        # -- Only one player has the most pieces.

        # -- Set winner and indicate game end.
        @winner = players_with_most[0]
      end
      # -- Game has ended.
      return true
    end

    # -- Game has not ended.
    return false
  end

  def redraw_board(message)
    system ("clear")
    @game_grid_view.display_grid

    puts

    @players.each do |player_id, player|
      puts "Player #{player.logo} piece count: #{player.get_piece_count}"
    end

    puts
    if message == nil
      puts "Turn: Player #{@current_player.logo}"
    else
      puts "Turn: Player #{@current_player.logo} - Status: #{message}"
    end

    puts
  end

  def get_player_piece(player_id, location)
    game_piece = @game_grid_model.get_game_piece(location)

    if game_piece != nil && game_piece.player_id == player_id
      # -- Game piece exists for player at given location.
      return game_piece
    else
      # -- Game piece does not exist for player at given location.
      return nil
    end
  end

  def assimilate_adjacent_enemies(attacking_player_piece)

    if !attacking_player_piece.is_a?(GamePieceModel)
      # -- Do nothing if piece is wrong class.
      return nil
    end

    # -- Create ranges for adjacent cells.
    x_start = attacking_player_piece.location_grid_point.x - 1
    x_end = attacking_player_piece.location_grid_point.x + 1
    y_start = attacking_player_piece.location_grid_point.y - 1
    y_end = attacking_player_piece.location_grid_point.y + 1

    # puts "Attacking piece: " + attacking_player_piece.location_id

    x_start.upto(x_end) do |x_coor|
      y_start.upto(y_end) do |y_coor|
        target_player_piece = @game_grid_model.get_game_piece(GridPointModel.new(x_coor, y_coor))
        if target_player_piece != nil &&
          target_player_piece.player_id != attacking_player_piece.player_id
          # -- Opponent piece exists in adjacent cell.

          # puts "Target piece: " + target_player_piece.location_id

          target_location = target_player_piece.location_id

          # -- Remove opponent piece to adjacent cell.
          remove_player_piece(target_player_piece)
          # -- Add attacking piece to adjacent cell.
          add_new_player_piece(attacking_player_piece.player_id, target_location)
        end
      end
    end

    # puts "Assimiation complete."
    # gets
  end

  def add_new_player_piece(player_id, location)
    # -- Create new player piece for given player_id.
    new_player_piece = GamePieceModel.new(player_id, @player_piece_design_lookup[player_id])
    if @game_grid_model.add_piece(new_player_piece, location) == nil
      # -- Unable to place piece on board so return nil.
      return nil
    else
      # -- Piece placed on board.

      # -- Register piece with player.
      @players[player_id].add_game_piece(new_player_piece)

      # -- Return new piece.
      return new_player_piece
    end
  end

  def remove_player_piece(player_piece)
    # -- Remove piece from board.
    @game_grid_model.remove_piece(player_piece)
    # -- Remove piece from player.
    @players[player_piece.player_id].remove_game_piece(player_piece)

  end

end

