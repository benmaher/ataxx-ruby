require 'set'

require './models/game_grid_cell_model.rb'
require './models/grid_point_model.rb'


class GameGridModel

  attr_reader 'x_size'
  attr_reader 'y_size'
  attr_reader 'column_labels'
  attr_reader 'row_labels'
  attr_reader 'unoccupied_locations'
  attr_reader 'occupied_locations'
  attr_reader 'target_locations'

  def initialize
    @x_size = 0
    @y_size = 0
    @size_set = false
    @grid_cells = []
    @grid_cell_lookup = {}
    @unoccupied_locations = Set.new
    @occupied_locations = Set.new
    @target_locations = []
  end

  def set_size(x, y)
    @x_size = x
    @y_size = y
    size_set = true
    build_grid
  end

  def build_grid

    @column_labels = []
    column_label = 'a'
    @x_size.times do
      @column_labels.push(column_label)
      column_label = (column_label.ord + 1).chr
    end

    @row_labels = []
    y_size.times do |y_index|
      @row_labels.push((y_size - y_index).to_s)
    end

    @grid_cell_lookup = {}
    @grid_cells = []
    @x_size.times do |x_index|
      @grid_cells[x_index] = []
      @y_size.times do |y_index|
        id = @column_labels[x_index] + @row_labels[y_index]
        grid_cell = GameGridCellModel.new(id, x_index, y_index)
        @grid_cells[x_index][y_index] = grid_cell
        @grid_cell_lookup[id] = grid_cell
      end
    end

    @unoccupied_locations.merge(@grid_cell_lookup.keys)
    @occupied_locations = Set.new
  end

  def add_piece(game_piece, location)
    # puts __method__

    grid_cell = get_grid_cell(location)

    if grid_cell == nil
      return nil
    else
      grid_cell.add_game_piece(game_piece)
      game_piece.set_game_grid_model(self)
      game_piece.set_location(grid_cell.id)
      update_available_moves_for_pieces
      @occupied_locations.add(grid_cell.id)
      @unoccupied_locations.delete(grid_cell.id)
      return game_piece
    end
  end

  def remove_piece(game_piece)
    grid_cell = get_grid_cell(game_piece.location_grid_point)
    if grid_cell != nil
      grid_cell.remove_game_piece(game_piece)
      game_piece.handle_removed_from_location
      update_available_moves_for_pieces
      @occupied_locations.delete(grid_cell.id)
      @unoccupied_locations.add(grid_cell.id)
    end
  end

  def get_game_piece(location)
    grid_cell = get_grid_cell(location)

    if grid_cell == nil
      return nil
    else
      return grid_cell.game_pieces[0]
    end
  end

  def set_target_locations(locations)
    if locations == nil
      @target_locations.clear
    else
      @target_locations = locations.select {|item| valid_location?(item)}
    end
  end

  def resolve_location(location)
    # puts __method__
    # puts location.inspect

    case location
    when GridPointModel
      if !valid_coordinates?(location.x, location.y)
        return nil
      end

      return @grid_cells[location.x][location.y].id

    when String
      location = location.gsub(/\s+/, "")
      return @grid_cell_lookup[location] == nil ? nil : location
    else
      return nil
    end

    # if stripped_location.length == 2
    #   column_label = stripped_location[0]
    #   row_label = stripped_location[1]
    #   x_coor = @column_labels.index(column_label)
    #   y_coor = @row_labels.index(row_label)
    #   if x_coor != nil and y_coor != nil
    #     puts "Decoded to: #{x_coor}, #{y_coor}"
    #     return GridPointModel.new(x_coor, y_coor)
    #   end
    # end
    # puts "Failed to decode"

  end

  def valid_coordinates?(x, y)
    return x >= 0 && x < x_size && y >= 0 && y < y_size
  end

  def get_grid_cell(location)
    return @grid_cell_lookup[resolve_location(location)]
  end

  def get_location_id(grid_point)
    if !grid_point.is_a?(GridPointModel)
      return nil
    end

  end

  def get_location_grid_point(location)
    grid_cell = get_grid_cell(location)
    if grid_cell == nil
      return nil
    else
      return GridPointModel.new(grid_cell.x, grid_cell.y)
    end
  end

  def valid_location?(location)
    return resolve_location(location) != nil
  end

  def occupied_location?(location)
    grid_cell = get_grid_cell(location)
    if grid_cell == nil
      return false
    else
      return grid_cell.occupied?
    end
  end

  def update_available_moves_for_pieces
    # puts __method__
    @grid_cell_lookup.values.each do |grid_cell|
      grid_cell.game_pieces.each do |game_piece|
        game_piece.update_available_moves
      end
    end
  end
end


