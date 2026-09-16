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

var eat_pieces = []

func load_data():
	pass

func restore():
	pass

func main():
	pass
