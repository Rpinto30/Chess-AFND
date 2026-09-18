class_name ChessPlayer
extends Node2D

var ID_PLAYER: int
var player_name: String
@export var chessBoard: Node2D
var board_points_extra: PointExtraChess
enum color_player {WHITE, BLACK}
@export var type_color_player : color_player

const init_pos_pieces = [
	[3,1,2,4,5,2,1,3],
	[0,0,0,0,0,0,0,0]
]

var pieces = []
var points: int = 0
#============TIME
var time: float
var count_timer: float
var end_time: bool = false
var enable_timer: bool = false

func init_time() -> void:
	if not enable_timer:
		enable_timer = true
		#print("Contador reanudado/iniciado.")

func stop_time() -> void:
	#print(enable_timer)
	if enable_timer:
		enable_timer = false
		#print("Contador frenado.")

func load_time(delta: float, label: Label) -> void:
	if enable_timer and not end_time:
		count_timer -= delta
		
		label.text = utils.formatear_tiempo(count_timer)
		#print(utils.formatear_tiempo(count_timer))
		# Verificación de llegada a 0
		if count_timer <= 0.0:
			count_timer = 0.0
			end_time = true
			enable_timer = false
			_al_terminar_tiempo()
	

func _al_terminar_tiempo() -> void:
	self.in_jaquemate = true

var my_king: Piece
var eat_pieces = []
var my_pieces = []

#============toma de desiciones=====
var danger_points = []
enum states_game  {NORMAL,JAQUE, JAQUEMATE}
var in_jaque: states_game
var in_jaquemate: bool
var last_move_notation: String
#tablas nio xd

var aten_piece: bool = false
var put_in_jaque_other: bool = false
var put_in_jaquemate_other: bool = false

#=========================MOVE PIECES================================
var added_points = []
var selected_piece = Vector2i(-1,-1)
func move_piece(board: Board, pos: Vector2i):
	#if is_instance_of(self, Bot):
	#	await get_tree().create_timer(2).timeout
	
	board_points_extra.clear()
	if is_instance_of(board.matrixRef[pos.y][pos.x], Piece):
		var eat_piece : Piece = board.matrixRef[pos.y][pos.x]
		eat_piece.eat_piece(self)
	
	var piece = board.matrixRef[selected_piece.y][selected_piece.x]
	var id_piece = board.matrixPos[selected_piece.y][selected_piece.x]
	
	var _dx = piece.actual_pos.x - pos.x
	var _dy = piece.actual_pos.y - pos.y
	
	if board.matrixPos[pos.y][pos.x] != 0:
		aten_piece = true
		print(board.matrixRef[pos.y][pos.x].select_type)
		print(self.points)
		self.points += utils.get_piece_value(
			board.matrixRef[pos.y][pos.x].select_type
		)
		print(self.points)
	else:
		aten_piece = false
	
	board.matrixRef[pos.y][pos.x] = piece
	board.matrixRef[selected_piece.y][selected_piece.x] = ""
	
	board.matrixPos[pos.y][pos.x] = id_piece
	board.matrixPos[selected_piece.y][selected_piece.x] = 0
	var pos_local = board.map_to_local(pos)
	var pos_global = board.to_global(pos_local)
	
	piece.global_position = pos_global
	piece.actual_pos = pos
	
	#==========enorque================
	if abs(_dx) == 2 and piece.select_type == 5:
		if _dx == -2: #derecha
			var rook = board.matrixRef[pos.y][7]
			if rook != null:
				enroque_move(board, rook, Vector2i(7,pos.y), Vector2i(piece.actual_pos.x-1, pos.y))
		else: #izquieda
			var rook = board.matrixRef[pos.y][0]
			if rook != null:
				enroque_move(board, rook, Vector2i(0,pos.y), Vector2i(piece.actual_pos.x+1, pos.y))
	else:
		#AGREGAR NOTACION
		last_move_notation = utils.set_notation(piece, pos, 
			self.aten_piece,
			put_in_jaque_other,
			put_in_jaquemate_other
		)
	
	#============condiciones============
	piece.is_first_move = false
	if pos.y == board.SIZE.y-1:
		piece.is_in_other_edge = true
	else:
		piece.is_in_other_edge = false
	
	board_points_extra.set_point(
		pos, Vector2i(2,3)
	)

func enroque_move(board: Board, rook: Piece, old_pos:Vector2i, new_pos: Vector2i):
	var id_piece = board.matrixPos[old_pos.y][old_pos.x]

	board.matrixRef[new_pos.y][new_pos.x] = rook
	board.matrixRef[old_pos.y][old_pos.x] = ""

		
	if board.matrixPos[new_pos.y][new_pos.x] != 0:
		aten_piece = true
	else:
		aten_piece = false

	board.matrixPos[new_pos.y][new_pos.x] = id_piece
	board.matrixRef[old_pos.y][old_pos.x] = 0
	var pos_local = board.map_to_local(new_pos)
	var pos_global = board.to_global(pos_local)

	rook.global_position = pos_global
	rook.actual_pos = new_pos
	rook.is_first_move = false

var temp_other_player_reference : ChessPlayer = null
func set_danger_points(other: ChessPlayer, board: Board, limits = true):
	if temp_other_player_reference == null:
		temp_other_player_reference = other

	other.danger_points = []
	#limits = true, own_piece = true, only_attack = true
	for piece in self.my_pieces:
		#print(is_instance_of(self, ChessPlayer))
		var r = piece.get_possible_moves(
			self,
			piece.actual_pos,
			board,
			piece.get_my_valid_moves(piece.actual_pos, board, self, limits, true, true),
			true #ownpieces
		)
		var new_ = r.filter(func(x): return not other.danger_points.has(x))
		
		other.danger_points.append_array(new_)
		if other.my_king.actual_pos in other.danger_points:
			put_in_jaque_other = true
		else:
			put_in_jaque_other = false

#ESTE MÉTODO SIRVE PARA LAS PIEZAS QUE PUEDEN BLOQUEAR UN JAQUE
#Estoy asegurado que aquí other ya está asignado por set_danget_points
func get_pieces_with_jaque(other: ChessPlayer, board: Board, limits = true):
	var result = []
	for piece in self.my_pieces:
		var r = piece.get_possible_moves(
			self,
			piece.actual_pos,
			board,
			piece.get_my_valid_moves(piece.actual_pos, board, self, limits, true)
		)
		#print(r)
		"""
		PARA P1: LOS MOVIMIENTOS PARA BLOQUEAR DEBEN ESTAR ARRIBA DEL REY
		PARA P2: LOS MOVIMIENTOS PARA BLOQUEAR DEBEN ESTAR ABAJO DEL REY
		"""
		if other.my_king.actual_pos in r:
			#print("Pieza que 've' al rey: ", piece.select_type, " en ", piece.actual_pos)
			var new_ = r.filter(func(x): return not result.has(x))
			
			var king_pos = other.my_king.actual_pos
			var attacker_pos = piece.actual_pos

			var direction = (attacker_pos - king_pos).sign()

			var max_steps = max(abs(attacker_pos.x - king_pos.x), abs(attacker_pos.y - king_pos.y))
			
			#print(new_)
			#Antes de filtarr todo, si pedes comerte a la pieza, se agreaga
			result.append(attacker_pos)

			var blocking_squares = []
			for step in range(1, max_steps):
				blocking_squares.append(king_pos + direction * step)

			new_ = new_.filter(func(item): return item in blocking_squares)
			"""
			new_ = new_.filter(func(item):
				var diff = item - king_pos

				if diff == Vector2i.ZERO:
					return false

				# diff debe ser un múltiplo entero exacto de "direction"
				if direction.x != 0 and diff.x % direction.x != 0:
					return false
				if direction.y != 0 and diff.y % direction.y != 0:
					return false

				var steps_x = diff.x / direction.x if direction.x != 0 else 0
				var steps_y = diff.y / direction.y if direction.y != 0 else 0

				# si ambos ejes se mueven, los pasos deben coincidir (línea recta real)
				if direction.x != 0 and direction.y != 0 and steps_x != steps_y:
					return false

				var steps = steps_x if direction.x != 0 else steps_y
				return steps >= 1 and steps <= max_steps
			)
			"""
			#print("new: ", new_)
			result.append_array(new_)
	return result

func check_jaque():
	if my_king.actual_pos in self.danger_points:
		in_jaque = states_game.JAQUE
		print(self.player_name, " ESTA EN JAQUE!")
	else: in_jaque = states_game.NORMAL

#JAQUE
func valid_moves_jaque(board: Board, piece: Piece):
	var p = piece.get_my_valid_moves(piece.actual_pos, board, self)
	var result = []
	if piece.select_type == 5: #king:
		for mov in p:
			print("[EN JAQUE]")
			#piece.player_owner.debug_set_points_danger()
			var r = utils.check_operation_vec_player(ID_PLAYER, piece.actual_pos, mov)
			#Actualiza sin limites el dangerPoint 
			temp_other_player_reference.set_danger_points(self, board, false) 
			
			if not r in self.danger_points:
				result.append(mov)
		return result
	else:
		var danger_moves = temp_other_player_reference.get_pieces_with_jaque(self, board, false)
		print(danger_moves)
		for mov in p:
			var r = utils.check_operation_vec_player(ID_PLAYER, piece.actual_pos, mov)
			if r in danger_moves:
				result.append(mov)
		return result

#JAQUEMATE
var already_jaquemate_validated = true
func valid_jaquemate(board:Board):
	already_jaquemate_validated = true
	if temp_other_player_reference != null:
		if len(self.my_pieces) > 1:
			var dup = self.my_pieces.duplicate()
			dup.erase(self.my_king)
			
			var no_king = []
			var nomral = []
			for p in dup:
				no_king.append_array(self.valid_moves_jaque(board, p))
				if self.in_jaque != self.states_game.JAQUE:
					nomral.append_array(p.get_my_valid_moves(p.actual_pos, board, self))
			
			
			var yes_king = self.valid_moves_jaque(board, self.my_king)
			print(no_king)
			print(yes_king)
			if not (no_king + yes_king + nomral):
				in_jaquemate = true
	else: return

#==================================POLIMORFIZMO ZONE===========================
func load_data(): pass
func restore(): pass
func main(): pass

# para el bot
func registrar_movimiento_player(_notacion: String):
	pass

func actualizar_emocion():
	pass
