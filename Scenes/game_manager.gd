class_name GameManager
extends Node2D
#====================GLOBAL REFERENCE======================
@export_category("GLOBAL REFERENCES")
@export var board_parent: Node2D
var board: Board

@export var label: Label

@export var player_ref: PackedScene
@export var bot_ref: PackedScene

#=======================GAME CONTROL=======================
@export_category("GAME CONTROL")
enum turns {P1, P2}
@export var turn = turns.P1
var players: Array[ChessPlayer]
var stylePieces: int = 0

#=======================LOAD =============================

func default_data(mode: String, color: int, style:int): # 1v1 | bot; 0: white | 1: black
	var player1: ChessPlayer = player_ref.instantiate()
	player1.player_name = "PLAYER 1"
	player1.chessBoard = board_parent
	player1.type_color_player = player1.color_player.BLACK if color == 1 else player1.color_player.WHITE
	player1.ID_PLAYER = 1
	player1.time = 600
	players.append(player1)
	get_tree().current_scene.add_child(player1)
	
	var player2: ChessPlayer
	if mode == "bot":
		player2 = bot_ref.instantiate()
		player2.player_name = "BOT"
	else:
		player2 = player_ref.instantiate()
		player2.player_name = "PLAYER 2"
	
	player2.chessBoard = board_parent
	player2.type_color_player = player2.color_player.BLACK if  player1.type_color_player == 0 else player2.color_player.WHITE	
	player2.ID_PLAYER = 2
	player1.time = 600
	players.append(player2)
	get_tree().current_scene.add_child(player2)
	
	player1.load_data()
	player2.load_data()
	stylePieces = style
	
func load_global_data():
	var player1: ChessPlayer = player_ref.instantiate()
	player1.player_name = GlobalManager.player1_name
	player1.chessBoard = board_parent
	player1.type_color_player = player1.color_player.BLACK if GlobalManager.side == 1 else player1.color_player.WHITE
	player1.ID_PLAYER = 1
	player1.time = GlobalManager.time
	players.append(player1)
	get_tree().current_scene.add_child(player1)
	
	var player2: ChessPlayer
	if GlobalManager.mode == "bot":
		player2 = bot_ref.instantiate()
		player2.bot_dificulty = GlobalManager.bot_difficulty
	else:
		player2 = player_ref.instantiate()
	player2.player_name = GlobalManager.player2_name
	player2.chessBoard = board_parent
	player2.type_color_player = player2.color_player.BLACK if player1.type_color_player == 0 else player2.color_player.WHITE	
	player2.ID_PLAYER = 2
	player2.time = GlobalManager.time
	players.append(player2)
	get_tree().current_scene.add_child(player2)
	
	player1.load_data()
	player2.load_data()
	stylePieces = GlobalManager.style

func _ready() -> void:
	#players = utils.obtener_nodos_por_tipo(self, ChessPlayer).slice(0,2)
	board = utils.obtener_nodos_por_tipo(board_parent, Board)[0]
	default_data('1vs1', 1, 1)
	#load_global_data()
	for i in players:
		set_pieces(i, i.ID_PLAYER)
		
	#p1
	if players[0].type_color_player == players[0].color_player.WHITE: turn = turns.P1
	else: turn = turns.P2
	
	utils.reveal_scene()

func set_pieces(player: ChessPlayer, color: int):
	var line = board.SIZE.x - 1 if color == 1 else 0 

	for y in player.init_pos_pieces:
		for x in range(len(y)):
			var pos_local = board.map_to_local(Vector2i(x, line))
			var pos_global = board.to_global(pos_local)
			var piece := board.instancePiece(
				pos_global,
				player.type_color_player,
				y[x],
				stylePieces
			)	
			if y[x] == 5: #king
				player.my_king = piece
			player.my_pieces.append(piece)
			piece.player_owner = player
			board.matrixPos[line][x] = color 
			board.matrixRef[line][x] =  piece
			piece.actual_pos = Vector2i(x, line)

		line = line - 1 if color == 1 else line + 1


func select_player_by_turn() -> ChessPlayer:
	var player: ChessPlayer
	if turn == turns.P1:
		player = players[0]
	else:
		player = players[1]
	return player
	
func select_other_by_turn() -> ChessPlayer:
	var player: ChessPlayer
	if turn == turns.P1:
		player = players[1]
	else:
		player = players[0]
	return player

func manager_turns():
	var player = select_player_by_turn()
	label.text = "Turno de: " + player.player_name
	player.main()
	if player.actual_state == player.states.END:
		if turn == turns.P1:  turn = turns.P2
		else: turn = turns.P1
		
		#aca cambia de turno, por eso uso otra vez select_player_by_turn()
		var other = select_player_by_turn()
		
		player.set_danger_points(other, board)
		other.check_jaque()
		player.restore()
		
		

"""
estados especiales:
- jaquemate (sin movimientos disponibles)
- jaque (rey)

- tablas (rey/rey - movimientos repetidos)
"""
func process_jaquemate() -> bool:
	return true

func process_draw() -> bool:
	return true

func _process(_delta: float) -> void:
	manager_turns()
	#process_jaque()
	
