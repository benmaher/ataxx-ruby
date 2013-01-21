class GameGridCellModel

  attr_reader 'x'
  attr_reader 'y'
  attr_reader 'id'
  attr_reader 'game_pieces'

  def initialize(id, x, y)
    @id = id
    @x = x
    @y = y
    @game_pieces = []
  end

  # def set_coordinates(x, y)
  #   @x_coordinate = x
  #   @y_coordinate = y
  # end

  def add_game_piece(game_piece)
    @game_pieces.push(game_piece)
    # puts @game_pieces.inspect
  end

  def remove_game_piece(game_piece)
    @game_pieces.delete(game_piece)
    # puts @game_pieces.inspect
  end

  def occupied?
    return @game_pieces.length != 0
  end
end

