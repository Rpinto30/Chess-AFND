class_name Player
extends ChessPlayer

@export var board_parent: Node2D
var board: Board
var board_points: PointChess

enum states { WAITING, SELECT, VALIDMOVE, INVALIDMOVE, END}
var actual_state = states.WAITING

func load_data() -> void:
	print(self.chessBoard.name)
	board = utils.obtener_nodos_por_tipo(self.chessBoard, Board)[0]
	board_points = utils.obtener_nodos_por_tipo(self.chessBoard, PointChess)[0]

	if not board.touched.is_connected(self.cap_signal):
		board.touched.connect(self.cap_signal)
	print("todo cargado")
	
#===================SET ADDED POINTS=======================
var added_points = []
var selected_piece = Vector2i(-1,-1)
func clear_board_points():
	for i in range(added_points.size() - 1, -1, -1):
		var point = added_points[i]
		board_points.remove_point(point)
		added_points.remove_at(i)

func set_board_points(piece_pos: Vector2i, possible_pos):
	for comb in possible_pos:
		var r = piece_pos-comb if ID_PLAYER == 1 else piece_pos+comb
		var condition = (Piece.filt_pos_limits(r, board) and 
		Piece.filt_pos_own(r, board, self))
		if condition:
			board_points.set_point(r, Vector2i(2,0))
			added_points.append(r)

func cap_signal(touched: bool, pos: Vector2i):
	if touched:
		selected_piece = Vector2i(-1,-1)
		clear_board_points()
		print(self.name, " toco: ", pos)
		if pos.x != -1 and pos.y != -1:
			var piece = board.matrixRef[pos.y][pos.x]
			selected_piece = pos
			if is_instance_of(piece, Piece):
				if piece.color == type_color_player:
					var p = piece.Pawn_valid_move()
					set_board_points(pos, p)
				#endOwnPiece
			#endIsInstance
		#endValidPos

	if added_points: 
		actual_state = states.SELECT
	
	if board.touched.is_connected(self.cap_signal):
		board.touched.disconnect(self.cap_signal)

#===================VERIFY VALID MOVE=======================
func move_piece(pos: Vector2i):
	if is_instance_of(board.matrixRef[pos.y][pos.x], Piece):
		var eat_piece = board.matrixRef[pos.y][pos.x]
		self.eat_pieces.append(eat_piece)
		self.points += 1
		self.get_parent().remove_child(eat_piece)
		
		print("Piezas comidas por: ", self.name)
		for i in self.eat_pieces:
			print(i.select_type)
			
	
	var piece = board.matrixRef[selected_piece.y][selected_piece.x]
	var id_piece = board.matrixPos[selected_piece.y][selected_piece.x]
	board.matrixRef[pos.y][pos.x] = piece
	board.matrixRef[selected_piece.y][selected_piece.x] = ""
	
	board.matrixPos[pos.y][pos.x] = id_piece
	board.matrixPos[selected_piece.y][selected_piece.x] = 0
	var pos_local = board.map_to_local(pos)
	var pos_global = board.to_global(pos_local)
	
	piece.global_position = pos_global
	actual_state = states.END

func cap_select(touched: bool, pos: Vector2i):
	if touched:
		#clear_board_points()
		if added_points.has(pos):
			print(pos, ": Puede moverse")
			actual_state = states.VALIDMOVE
			move_piece(pos)
		else:
			print("MOVIMIENTO NO VALIDO ----------")
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
		print("Esperando a que el tablero esté listo...")
		return 
	match actual_state:
		states.WAITING:
			if not board.touched.is_connected(self.cap_signal):
				board.touched.connect(self.cap_signal)
		states.SELECT:
			if not board.touched.is_connected(self.cap_select):
				board.touched.connect(self.cap_select)
		states.INVALIDMOVE:
			actual_state = states.WAITING
		states.END:
			pass#restore()
	
