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

var color: color_player
var select_type: Type
var player_owner: ChessPlayer
var actual_pos: Vector2i

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
	
	print("Piezas comidas por: ", self.name)
	if self.player_owner.my_pieces.has(self):
		self.player_owner.my_pieces.erase(self)
	print(self.player_owner.my_pieces)

func get_possible_moves(player:ChessPlayer,pos: Vector2i, board:Board, movements: Array):
	var valids = []
	for comb in movements:
		var r = pos-comb if player.ID_PLAYER == 1 else pos+comb
		var condition = (Piece.filt_pos_limits(r, board) and 
		Piece.filt_pos_own(r, board, player))
		if condition:
			valids.append(r)
			#board_points.set_point(r, Vector2i(2,0))
			#added_points.append(r)
	return valids
	
func Pawn_valid_move():
	return [
		Vector2i(1,1), 
		Vector2i(-1,1), 
		Vector2i(0,1), 
		Vector2i(0,2)
	] 
