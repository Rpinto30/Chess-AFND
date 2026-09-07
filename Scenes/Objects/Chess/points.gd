extends TileMapLayer

func set_point(pos: Vector2, tile: Vector2i):
	set_cell(pos, 0, tile)
	print("[POINTS] Set at: ", pos)

func remove_point(pos: Vector2):
	set_cell(pos, -1)
	print("[POINTS] Remove at: ", pos)
