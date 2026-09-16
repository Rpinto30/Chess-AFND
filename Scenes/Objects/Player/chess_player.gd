class_name ChessPlayer
extends Node2D

var ID_PLAYER: int
var player_name: String
@export var chessBoard: Node2D
enum color_player {WHITE, BLACK}
@export var type_color_player : color_player

const init_pos_pieces = [
	[3,2,1,4,5,1,2,3],
	[0,0,0,0,0,0,0,0]
]

var pieces = []
var points: int = 0
var time: float

var my_king: Piece
var eat_pieces = []
var my_pieces = []

#============toma de desiciones=====
var danger_points = []
enum states_game  {NORMAL,JAQUE, JAQUEMATE}
var in_jaque: states_game
var in_jaquemate: bool
#tablas nio xd

#=========================MOVE PIECES================================
var added_points = []
var selected_piece = Vector2i(-1,-1)
func move_piece(board: Board, pos: Vector2i):
	if is_instance_of(board.matrixRef[pos.y][pos.x], Piece):
		var eat_piece : Piece = board.matrixRef[pos.y][pos.x]
		eat_piece.eat_piece(self)
	
	var piece = board.matrixRef[selected_piece.y][selected_piece.x]
	var id_piece = board.matrixPos[selected_piece.y][selected_piece.x]
	board.matrixRef[pos.y][pos.x] = piece
	board.matrixRef[selected_piece.y][selected_piece.x] = ""
	
	board.matrixPos[pos.y][pos.x] = id_piece
	board.matrixPos[selected_piece.y][selected_piece.x] = 0
	var pos_local = board.map_to_local(pos)
	var pos_global = board.to_global(pos_local)
	
	piece.global_position = pos_global
	piece.actual_pos = pos

func set_danger_points(other: ChessPlayer, board: Board):
	other.danger_points.clear()
	for piece in self.my_pieces:
		var r = piece.get_possible_moves(
			self,
			piece.actual_pos,
			board,
			piece.Pawn_valid_move()
		)
		var new_ = r.filter(func(x): return not other.danger_points.has(x))
		other.danger_points.append_array(new_)


func check_jaque():
	if my_king.actual_pos in self.danger_points:
		in_jaque = states_game.JAQUE
	else: in_jaque = states_game.NORMAL


#TODO MEJORAR ALGORITMO DE MOVER PIEZAS CON JAQUE Y DETECTAR JAQUEMATE
func valid_moves_jaque(piece: Piece):
	var p = piece.Pawn_valid_move()
	var result = []
	
	if piece.select_type == 5: #king:
		for mov in p:
			var r = utils.check_operation_vec_player(ID_PLAYER, piece.actual_pos, mov)
			if not r in self.danger_points:
				result.append(mov)
				print(r)
				print(self.danger_points)
		return result
	else:
		for mov in p:
			var r = utils.check_operation_vec_player(ID_PLAYER, piece.actual_pos, mov)
			if r in self.danger_points:
				#Agregar un mejor manejo de jaques
				result.append(mov)
		return result



#==================================POLIMORFIZMO ZONE===========================
func load_data(): pass
func restore(): pass
func main(): pass
