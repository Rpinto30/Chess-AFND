class_name ChessPlayer
extends Node2D

var ID_PLAYER: int
var player_name: String
@export var chessBoard: Node2D
enum color_player {WHITE, BLACK}
@export var type_color_player : color_player

const init_pos_pieces = [
	[3,2,1,5,4,1,2,3],
	[0,0,0,0,0,0,0,0]
]

var pieces = []
var points: int = 0
var time: float

var my_king: Piece
var eat_pieces = []
var my_pieces = []

#=========================MOVE PIECES================================
var added_points = []
var selected_piece = Vector2i(-1,-1)
func move_piece(board: Board, pos: Vector2i):
	if is_instance_of(board.matrixRef[pos.y][pos.x], Piece):
		var eat_piece : Piece = board.matrixRef[pos.y][pos.x]
		eat_piece.eat_piece(self)
	
	var piece = board.matrixRef[selected_piece.y][selected_piece.x]
	var id_piece = board.matrixPos[selected_piece.y][selected_piece.x]
	board.matrixRef[pos.y][pos.x] = piece
	board.matrixRef[selected_piece.y][selected_piece.x] = ""
	
	board.matrixPos[pos.y][pos.x] = id_piece
	board.matrixPos[selected_piece.y][selected_piece.x] = 0
	var pos_local = board.map_to_local(pos)
	var pos_global = board.to_global(pos_local)
	
	piece.global_position = pos_global
	piece.actual_pos = pos


func load_data():
	pass

func restore():
	pass

func main():
	pass
