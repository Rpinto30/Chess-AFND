class_name ValidMoves 
extends RefCounted

#Rectos
const R = [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]
#Diagonales
const D = [Vector2i(1, 1), Vector2i(1, -1), Vector2i(-1, 1), Vector2i(-1, -1)]
#En L
const L = [
	Vector2i(1, 2), Vector2i(-1, 2), Vector2i(2, 1), Vector2i(-2, 1),
	Vector2i(1, -2), Vector2i(-1, -2), Vector2i(2, -1), Vector2i(-2, -1)
]


static func _movimientos_rectos(board: Board, start: Vector2i, player: ChessPlayer, max_n: int, limits = true, own_piece = false) -> Array:
	var validos = []
	for dir in R:
		for n in range(1, max_n + 1): 
			var pos = utils.check_operation_vec_player(player.ID_PLAYER, start, dir*n)
			if not Piece.filt_pos_limits(pos, board):
				break
			var cell = board.matrixPos[pos.y][pos.x]
			if cell == 0:
				validos.append(dir * n)
			elif cell == player.ID_PLAYER:
				if own_piece:
					validos.append(dir * n)
				break 
			else:
				validos.append( dir * n)
				if limits:
					break
	return validos

static func _movimientos_diagonales(board: Board, start: Vector2i, player: Player, max_n: int, limits = true, own_piece = false) -> Array:
	var validos = []
	for dir in D:
		for n in range(1, max_n + 1):
			var pos = utils.check_operation_vec_player(player.ID_PLAYER, start, dir*n)
			if not Piece.filt_pos_limits(pos, board):
				break
			var cell = board.matrixPos[pos.y][pos.x]
			if cell == 0:
				validos.append(dir*n)
			elif cell == player.ID_PLAYER:
				if own_piece:
					validos.append(dir * n)
				break
			else:
				validos.append(dir*n)
				if limits: 
					break
	return validos

static func _movimientos_L(board: Board, start: Vector2i, player: ChessPlayer, own_piece = false) -> Array:
	var validos = []
	for dir in L:
		var pos =  utils.check_operation_vec_player(player.ID_PLAYER, start, dir)
		if Piece.filt_pos_limits(pos, board):
			if not own_piece:
				if board.matrixPos[pos.y][pos.x] != player.ID_PLAYER:
					validos.append(dir)
			else:
				validos.append(dir)
	return validos

#Peones
static func mov_peon(board: Board, player: ChessPlayer, pos: Vector2i, is_first: bool, own_piece = false, only_attack = false) -> Array:
	var validos = []
	if not only_attack:
		# Movimiento recto
		var r = Vector2i(0, 1)
		#if Piece.filt_pos_limits(r, board) and board.matrixPos[r.y][r.x] == 0:
		var pos1 = utils.check_operation_vec_player(player.ID_PLAYER, pos, r)
		if board.matrixPos[pos1.y][pos1.x] == 0:
			validos.append(r)
			if is_first: 
				#var pos_f2 = Vector2i(0, 2)
				#if board.matrixPos[pos_f2.y][pos_f2.x] == 0:
				validos.append(Vector2i(0, 2))
		
	#Ataques diagonales
	for v in [Vector2i(-1,0),Vector2i(1,0)]:
		var atk = Vector2i(0, 1)
		var pos_atk = utils.check_operation_vec_player(player.ID_PLAYER, pos, atk)
		pos_atk += v
		atk += v
		
		if Piece.filt_pos_limits(pos_atk, board):
			var cell = board.matrixPos[pos_atk.y][pos_atk.x]
			if not own_piece:
				if cell != 0 and cell != player.ID_PLAYER:
					validos.append(atk)
			else:
				validos.append(atk)
	return validos


#Caballos
static func mov_caballo(board: Board, start: Vector2i, player: ChessPlayer, own_piece = false) -> Array:
	return _movimientos_L(board, start, player, own_piece)

#Alfiles
static func mov_alfil(board: Board, start: Vector2i, player: Player, limits= true, own_piece = false) -> Array:
	return _movimientos_diagonales(board, start, player, board.SIZE.x, limits, own_piece) 

#Torres
static func mov_torre(board: Board, start: Vector2i, player: ChessPlayer, limits = true, own_piece = false) -> Array:
	return _movimientos_rectos(board, start, player, board.SIZE.x, limits, own_piece)

#Reina
static func mov_reina(board: Board, start: Vector2i, player:ChessPlayer, limits=true, own_piece = false) -> Array:
	# Combina rectos y diagonales
	var validos = _movimientos_rectos(board, start, player, board.SIZE.x, limits, own_piece)
	validos.append_array(_movimientos_diagonales(board, start, player, board.SIZE.x, limits, own_piece))
	return validos

#Rey
static func mov_rey(board: Board, start: Vector2i, player: ChessPlayer, own_piece = false) -> Array:
	# Igual que la reina pero solo con una casilla 
	var r = _movimientos_rectos(board, start, player, 1, own_piece)
	r.append_array(_movimientos_diagonales(board, start, player, 1, true, own_piece))
	
	var validos = []

	for n in r:
		if not utils.check_operation_vec_player(player.ID_PLAYER, start, n) in player.danger_points:
			validos.append(n)
	
	return validos

#0 left; 1 right
static func cast_ling(board: Board, start: Vector2i, player: ChessPlayer, is_first:bool) -> Array:
	var validos = []
	if is_first:
		var rooks = []
		for piece in player.my_pieces:
			if piece.select_type == 3: #rook
				rooks.append(piece)
		
		#solo horizontales
		for rk in rooks:
			if rk.actual_pos.x == 0:
				if rk.is_first_move: 
					var valid = true
					for n in range(1,3):
						var pos = utils.check_operation_vec_player(player.ID_PLAYER, start, Vector2i(-n,0))
						if board.matrixPos[pos.y][pos.x] != 0:
							valid = false
						
						if valid:
							validos.append(Vector2i(-2,0))
			elif rk.actual_pos.x == board.SIZE.x-1:
				if rk.is_first_move: 
					var valid = true
					for n in range(1,3):
						var pos = utils.check_operation_vec_player(player.ID_PLAYER, start, Vector2i(n,0))
						if board.matrixPos[pos.y][pos.x] != 0:
							valid = false
						if valid:
							validos.append(Vector2i(2,0))
		return validos
	else:
		return []	
	
	
