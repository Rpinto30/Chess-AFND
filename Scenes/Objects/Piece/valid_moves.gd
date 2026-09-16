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

#Peones
static func mov_peon(board: Board, start: Vector2i, color_id: int, is_first: bool) -> Array:
	var validos = []
	var forward = -1 if color_id == 1 else 1 
	
	# Movimiento recto
	var pos_f1 = start + Vector2i(0, forward)
	if Piece.filt_pos_limits(pos_f1, board) and board.matrixPos[pos_f1.y][pos_f1.x] == 0:
		validos.append(pos_f1)
		if is_first: # Solo si es su primer movimiento[cite: 1]
			var pos_f2 = start + Vector2i(0, forward * 2)
			if board.matrixPos[pos_f2.y][pos_f2.x] == 0:
				validos.append(pos_f2)
	
	#Ataques diagonales
	var attacks = [Vector2i(1, forward), Vector2i(-1, forward)]
	for atk in attacks:
		var pos_atk = start + atk
		if Piece.filt_pos_limits(pos_atk, board):
			var cell = board.matrixPos[pos_atk.y][pos_atk.x]
			if cell != 0 and cell != color_id:
				validos.append(pos_atk)
	return validos


#Caballos
static func mov_caballo(board: Board, start: Vector2i, color_id: int) -> Array:
	return movimientos_L(board, start, color_id)

#Alfiles
static func mov_alfil(board: Board, start: Vector2i, color_id: int) -> Array:
	return movimientos_diagonales(board, start, color_id, 8) 

#Torres
static func mov_torre(board: Board, start: Vector2i, color_id: int) -> Array:
	return movimientos_rectos(board, start, color_id, 8)

#Reina
static func mov_reina(board: Board, start: Vector2i, color_id: int) -> Array:
	# Combina rectos y diagonales
	var validos = movimientos_rectos(board, start, color_id, 8)
	validos.append_array(movimientos_diagonales(board, start, color_id, 8))
	return validos

#Rey
static func mov_rey(board: Board, start: Vector2i, color_id: int) -> Array:
	# Igual que la reina pero solo con una casilla 
	var validos = movimientos_rectos(board, start, color_id, 1)
	validos.append_array(movimientos_diagonales(board, start, color_id, 1))
	return validos
