class_name ValidMoves extends RefCounted

#Rectos
const R = [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]
#Diagonales
const D = [Vector2i(1, 1), Vector2i(1, -1), Vector2i(-1, 1), Vector2i(-1, -1)]
#En L
const L = [
	Vector2i(1, 2), Vector2i(-1, 2), Vector2i(2, 1), Vector2i(-2, 1),
	Vector2i(1, -2), Vector2i(-1, -2), Vector2i(2, -1), Vector2i(-2, -1)
]


static func movimientos_rectos(board: Board, start: Vector2i, color_id: int, max_n: int) -> Array:
	var validos = []
	for dir in R:
		for n in range(1, max_n + 1): 
			var pos = start + (dir * n)
			if not Piece.filt_pos_limits(pos, board):
				break
			var cell = board.matrixPos[pos.y][pos.x]
			if cell == 0:
				validos.append(pos)
			elif cell == color_id:
				break 
			else:
				validos.append(pos)
				break
	return validos

static func movimientos_diagonales(board: Board, start: Vector2i, color_id: int, max_n: int) -> Array:
	var validos = []
	for dir in D:
		for n in range(1, max_n + 1):
			var pos = start + (dir * n)
			if not Piece.filt_pos_limits(pos, board):
				break
			var cell = board.matrixPos[pos.y][pos.x]
			if cell == 0:
				validos.append(pos)
			elif cell == color_id:
				break
			else:
				validos.append(pos)
				break
	return validos

static func movimientos_L(board: Board, start: Vector2i, color_id: int) -> Array:
	var validos = []
	for dir in L:
		var pos = start + dir
		if Piece.filt_pos_limits(pos, board):
			if board.matrixPos[pos.y][pos.x] != color_id:
				validos.append(pos)
	return validos

