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

static func filt_pos_limits(pos: Vector2i, board: Board):
	if ((0 <= pos.x and pos.x < board.SIZE.x) and 
		(0 <= pos.y and pos.y < board.SIZE.y)):
		return true
	else: return false

static func filt_pos_own(pos: Vector2i, b:Board, player: ChessPlayer):
	var ref = b.matrixPos[pos.y][pos.x]
	if ref == 0 and ref != player.ID_PLAYER:
		return true
	else: return false

func Pawn_valid_move():
	return [
		Vector2i(1,1), 
		Vector2i(-1,1), 
		Vector2i(0,1), 
		Vector2i(0,2)
	] 
