class GamePieceModel

  attr_accessor 'player_id'
  attr_reader 'location_id'
  attr_reader 'location_grid_point'
  attr_reader 'available_moves'
  attr_reader 'display_name'

  def initialize(player_id, display_name)
    @player_id = player_id
    @location_id = nil
    @location_grid_point = nil
    @available_moves = []
    @game_grid_model = nil
    @display_name = display_name == nil ? "#{player_id}" : "#{display_name}"
  end

  def set_game_grid_model(game_grid_model)
    @game_grid_model = game_grid_model
  end

  def set_location(location)
    @location_id = @game_grid_model.resolve_location(location)

    if @location_id != nil
      @location_grid_point = @game_grid_model.get_location_grid_point(@location_id)
    end
  end

  def handle_removed_from_location
    @location_id = nil
    @location_grid_point = nil
    @available_moves = []
    @game_grid_model = nil
  end

  def allowed_move?(move_location)
    return @available_moves.include?(@game_grid_model.resolve_location(move_location))
  end

  def update_available_moves
    @available_moves.clear

    x_start = @location_grid_point.x - 2
    x_end = @location_grid_point.x + 2
    y_start = @location_grid_point.y - 2
    y_end = @location_grid_point.y + 2

    x_start.upto(x_end) do |x_coor|
      y_start.upto(y_end) do |y_coor|
        target_location_id = @game_grid_model.resolve_location(GridPointModel.new(x_coor, y_coor))
        if @game_grid_model.valid_location?(target_location_id) &&
          !@game_grid_model.occupied_location?(target_location_id)

          @available_moves.push(target_location_id)
        end
      end
    end
  end

end
