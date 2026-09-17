class_name Piece
extends Node2D

enum Type { 
	Pawn, #0 
	Knightm, #1 
	Bishop, #2
	Rook, #3
	Queen, #4
	King #5
}
enum color_player {WHITE, BLACK}

var list_data = ["Pawn", #0 
	"Knightm", #1 
	"Bishop", #2
	"Rook", #3
	"Queen", #4
	"King"] #5


#===========================DATOS GENERALES=======================
var color: color_player
var select_type: Type
var player_owner: ChessPlayer
var actual_pos: Vector2i

#===========================CONDICIONES RELEVANTES=======================
var is_first_move: bool = true
var is_in_other_edge: bool = false

static func filt_jaque_pos(player: ChessPlayer, pos: Vector2i, piece):
	if piece.select_type == 5: #king
		if pos in player.danger_points: return false
		else: return true
	else:
		if pos in player.danger_points: return true
		else: return false
	

static func filt_pos_limits(pos: Vector2i, board: Board):
	if ((0 <= pos.x and pos.x < board.SIZE.x) and 
		(0 <= pos.y and pos.y < board.SIZE.y)):
		return true
	else: return false

static func filt_pos_own(pos: Vector2i, b:Board, player: ChessPlayer):
	var ref = b.matrixPos[pos.y][pos.x]
	if ref != player.ID_PLAYER:
		return true
	else: return false
	
func eat_piece(player: ChessPlayer):
	player.eat_pieces.append(self)
	player.points += 1
	player.get_parent().remove_child(self)
	
	if self.player_owner.my_pieces.has(self):
		self.player_owner.my_pieces.erase(self)

func get_possible_moves(player:ChessPlayer, pos: Vector2i, board:Board, movements: Array, own_piece= false):
	var valids = []
	for comb in movements:
		var r = utils.check_operation_vec_player(player.ID_PLAYER, pos, comb)
		#var r = pos-comb if player.ID_PLAYER == 1 else pos+comb
		var condition = false
		if own_piece:
			condition = Piece.filt_pos_limits(r, board)
		else:
			condition = (Piece.filt_pos_limits(r, board) and 
						Piece.filt_pos_own(r, board, player)) 
						
		if condition:
			valids.append(r)
	return valids

func get_my_valid_moves(pos: Vector2i, board: Board, player: ChessPlayer, 
	limits = true, own_piece = false, only_attack = false):
	match select_type:
		Type.Pawn:
			return ValidMoves.mov_peon(board, player, pos, self.is_first_move, own_piece, only_attack)
		Type.Knightm:
			return ValidMoves.mov_caballo(board, pos, player, own_piece)
		Type.Bishop:
			return ValidMoves.mov_alfil(board, pos, player, limits, own_piece)
		Type.Rook:
			return ValidMoves.mov_torre(board, pos, player, limits, own_piece)
		Type.Queen:
			return ValidMoves.mov_reina(board, pos, player, limits, own_piece)
		Type.King:
			var r =  ValidMoves.mov_rey(board, pos, player, own_piece)
			r.append_array(ValidMoves.cast_ling(board, pos, player, self.is_first_move))
			return r

#func Pawn_valid_move():
#	return [
#		Vector2i(1,1), 
#		Vector2i(-1,1), 
#		Vector2i(0,1), 
#		Vector2i(0,2)
#	] 
