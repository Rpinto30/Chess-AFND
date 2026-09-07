class_name ChessPlayer
extends Node2D

@export var chessBoard: Node2D
enum color_player {WHITE, BLACK}
@export var type_color_player : color_player

const init_pos_pieces = [
	[3,2,1,5,4,1,2,3],
	[0,0,0,0,0,0,0,0]
]

var pieces = []
var points: int
