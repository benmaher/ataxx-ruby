class GameGridView

  attr_reader 'game_grid_model'

  def initialize(game_grid_model)
    @game_grid_model = game_grid_model
  end

  def display_row_border
    print "  |"
    @game_grid_model.x_size.times do
      print "---|"
    end
    puts
  end

  def display_row(row_index)
    print "|"
    @game_grid_model.x_size.times do |column_index|
      location = @game_grid_model.resolve_location(GridPointModel.new(column_index, row_index))

      game_piece = @game_grid_model.get_game_piece(location)
      if game_piece == nil
        if @game_grid_model.target_locations.include?(location)
          print " . |"
        else
          print "   |"
        end
      else
        printf(" %s |", game_piece.display_name)
      end
    end
  end

  def display_column_labels
    print "   "
    @game_grid_model.x_size.times do |x_index|
      printf(" %s  ", @game_grid_model.column_labels[x_index])
    end
    puts
  end

  def display_grid

    display_column_labels
    @game_grid_model.y_size.times do |y_index|
      display_row_border
      printf("%d ", @game_grid_model.row_labels[y_index])
      display_row(y_index)
      printf(" %d\n", @game_grid_model.row_labels[y_index])
    end
    display_row_border
    display_column_labels

  end



end
