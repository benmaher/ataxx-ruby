class PlayerModel
  attr_reader 'id'
  attr_reader 'logo'

  def initialize(id, logo)
    @id = id
    @logo = logo == nil ? "#{id}" : "#{logo}"
    @game_pieces = []
  end

  def add_game_piece(game_piece)
    @game_pieces.push(game_piece)
  end

  def remove_game_piece(game_piece)
    @game_pieces.delete(game_piece)
  end

  def get_piece_count
    return @game_pieces.length
  end

  def has_pieces?
    return @game_pieces.length > 0
  end

  def has_moves?
    @game_pieces.each do |game_piece|
      if game_piece.available_moves.length != 0
        return true
      end
    end
    return false
  end


end
