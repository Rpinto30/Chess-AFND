class_name PointExtraChess
extends TileMapLayer

func set_point(pos: Vector2, tile: Vector2i):
	set_cell(pos, 0, tile)


func remove_point(pos: Vector2):
	set_cell(pos, -1)
