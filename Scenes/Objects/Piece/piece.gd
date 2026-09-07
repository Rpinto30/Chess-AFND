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
var list_data = ["Pawn", #0 
	"Knightm", #1 
	"Bishop", #2
	"Rook", #3
	"Queen", #4
	"King"] #5
@export var select_type: Type

func set_movments():
	pass
