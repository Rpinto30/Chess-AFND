class_name Player
extends ChessPlayer

@export var board_parent: Node2D
var board: Board
var board_points: PointChess

enum states { WAITING, SELECT, VALIDMOVE, INVALIDMOVE, END}
var actual_state = states.WAITING

func load_data() -> void:
	board = utils.obtener_nodos_por_tipo(self.chessBoard, Board)[0]
	board_points = utils.obtener_nodos_por_tipo(self.chessBoard, PointChess)[0]

	if not board.touched.is_connected(self.cap_signal):
		board.touched.connect(self.cap_signal)
	
#===================SET ADDED POINTS=======================
func clear_board_points():
	for i in range(added_points.size() - 1, -1, -1):
		var point = added_points[i]
		board_points.remove_point(point)
		added_points.remove_at(i)

func debug_clear_points_danger():
	for i in danger_points:
		board_points.remove_point(i)

func debug_set_points_danger():	
	for i in danger_points:
		if self.ID_PLAYER == 1:
			board_points.set_point(i, Vector2i(2,1))
		else:
			board_points.set_point(i, Vector2i(2,2))

func set_board_points(piece_pos: Vector2i, possible_pos, type_point: Vector2i = Vector2i(2,0)):
	for comb in possible_pos:
		var r = utils.check_operation_vec_player(ID_PLAYER, piece_pos, comb)
		#FILTROS DE MOVIMIENTO
		var condition = (Piece.filt_pos_limits(r, board) and 
		Piece.filt_pos_own(r, board, self))
	
		if condition:
			board_points.set_point(r, type_point)
			added_points.append(r)

func cap_signal(touched: bool, pos: Vector2i):
	if touched:
		selected_piece = Vector2i(-1,-1)
		clear_board_points()
		#debug_clear_points_danger()
		if pos.x != -1 and pos.y != -1:
			var piece = board.matrixRef[pos.y][pos.x]
			selected_piece = pos
			if is_instance_of(piece, Piece):
				if piece.color == type_color_player:
					var p = []
					if not self.in_jaque:
						p = piece.get_my_valid_moves(pos, board, self)
						#debug_set_points_danger()
						set_board_points(pos, p)
					else:
						p = self.valid_moves_jaque(board,piece)
						set_board_points(pos, p, Vector2i(2,2))
						#if p: self.in_jaque = self.states_game.NORMAL
						self.already_jaquemate_validated = false
					
				#endOwnPiece
			#endIsInstance
		#endValidPos

	if added_points: 
		actual_state = states.SELECT
	
	if board.touched.is_connected(self.cap_signal):
		board.touched.disconnect(self.cap_signal)

#===================VERIFY VALID MOVE=======================

func cap_select(touched: bool, pos: Vector2i):
	if touched:
		#clear_board_points()
		if added_points.has(pos):
			actual_state = states.VALIDMOVE
			move_piece(board, pos)
			actual_state = states.END
			#debug_clear_points_danger()
		else:
			actual_state = states.INVALIDMOVE
			restore()
			cap_signal(touched, pos)
	board.touched.disconnect(self.cap_select)
	
func restore():
	actual_state = states.WAITING
	clear_board_points()
	selected_piece = Vector2i(-1,-1)

func main():
	if board == null:
		return 
	match actual_state:
		states.WAITING:
			if not self.already_jaquemate_validated:
				self.valid_jaquemate(board)
			if not board.touched.is_connected(self.cap_signal):
				board.touched.connect(self.cap_signal)
		states.SELECT:
			if not board.touched.is_connected(self.cap_select):
				board.touched.connect(self.cap_select)
		states.INVALIDMOVE:
			actual_state = states.WAITING
		states.END:
			pass#restore()
	
