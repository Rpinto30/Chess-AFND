class_name GameManager
extends Node2D
#====================GLOBAL REFERENCE======================
@export_category("GLOBAL REFERENCES")
@export var board_parent: Node2D
var board: Board

#=======UI
@export var MainUI: Control
var lp1_name: Label
var lp1_time: Label
var lp1_points: Label
var lp1_turn: Label

var lp2_name: Label
var lp2_time: Label
var lp2_points: Label
var lp2_turn: Label

var jugadas_label: Label

@export var player_ref: PackedScene
@export var bot_ref: PackedScene

#=======================GAME CONTROL=======================
@export_category("GAME CONTROL")
enum turns {P1, P2}
@export var turn = turns.P1
var players: Array[ChessPlayer]
var stylePieces: int = 0
var won: bool
#=======================LOAD =============================

func default_data(mode: String, color: int, style:int): # 1v1 | bot; 0: white | 1: black
	var player1: ChessPlayer = player_ref.instantiate()
	player1.player_name = "PLAYER 1"
	player1.chessBoard = board_parent
	player1.type_color_player = player1.color_player.BLACK if color == 1 else player1.color_player.WHITE
	player1.ID_PLAYER = 1
	player1.time = 600
	player1.count_timer = player1.time
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
	player2.time = 600
	player2.count_timer = player2.time
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
	player1.count_timer = player1.time
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
	player2.count_timer = player2.time
	players.append(player2)
	get_tree().current_scene.add_child(player2)
	
	player1.load_data()
	player2.load_data()
	stylePieces = GlobalManager.style

func _ready() -> void:
	#players = utils.obtener_nodos_por_tipo(self, ChessPlayer).slice(0,2)
	#======SEARCH UI
	lp1_name = utils.obtener_nodos_por_nombre(MainUI, "Player1NameLabel")[0]
	lp2_name = utils.obtener_nodos_por_nombre(MainUI, "Player2NameLabel")[0]
	
	lp1_time = utils.obtener_nodos_por_nombre(MainUI, "Player1TimeLabel")[0]
	lp2_time = utils.obtener_nodos_por_nombre(MainUI, "Player2TimeLabel")[0]
	
	lp1_points = utils.obtener_nodos_por_nombre(MainUI, "Player1ScoreLabel")[0]
	lp2_points = utils.obtener_nodos_por_nombre(MainUI, "Player2ScoreLabel")[0]
	
	lp1_turn =  utils.obtener_nodos_por_nombre(MainUI, "Player1Turn")[0]
	lp2_turn =  utils.obtener_nodos_por_nombre(MainUI, "Player2Turn")[0]
	
	jugadas_label =  utils.obtener_nodos_por_nombre(MainUI, "Jugadas")[0]
	#===============================================
	board = utils.obtener_nodos_por_tipo(board_parent, Board)[0]
	
	load_global_data()
	lp1_name.text = GlobalManager.player1_name
	lp2_name.text = GlobalManager.player2_name
	#default_data('bot', 0, 0)
	for i in players:
		set_pieces(i, i.ID_PLAYER)
		
	#p1
	if players[0].type_color_player == players[0].color_player.WHITE:
		lp1_name.add_theme_color_override('font_color', Color.WHITE)
		lp1_name.add_theme_color_override('font_outline_color', Color.BLACK)
		
		lp2_name.add_theme_color_override('font_color', Color.BROWN)
		lp2_name.add_theme_color_override('font_outline_color', Color.WHITE)
		
		turn = turns.P1
	else: 
		lp2_name.add_theme_color_override('font_color', Color.WHITE)
		lp2_name.add_theme_color_override('font_outline_color', Color.BLACK)
		
		lp1_name.add_theme_color_override('font_color', Color.BROWN)
		lp1_name.add_theme_color_override('font_outline_color', Color.WHITE)
		turn = turns.P2
	
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
	#label.text = "Turno de: " + player.player_name
	player.main()
	player.init_time()
	
	#CAMBIO DE TURNO
	if player.actual_state == player.states.END:
		if turn == turns.P1:  
			turn = turns.P2
			lp2_turn.show()
			lp1_turn.hide()
		else: 
			turn = turns.P1
			lp1_turn.show()
			lp2_turn.hide()
		#aca cambia de turno, por eso uso otra vez select_player_by_turn()
		var other = select_player_by_turn() #p1 -> p2
		player.set_danger_points(other, board)
		player.stop_time()
		if player.aten_piece:
			if player.ID_PLAYER == 1:
				lp1_points.text = str(player.points)
			if player.ID_PLAYER == 2:
				lp2_points.text = str( player.points)
		
		if is_instance_of(other, Bot):
			print("El jugador responde con: ",player.last_move_notation)
			other.registrar_movimiento_player(player.last_move_notation)
		other.check_jaque()
		player.restore()
		#CADENA DE JUGADAS
		if player.type_color_player == 1:
			jugadas_label.text += "○"
		else: jugadas_label.text += "●"
		jugadas_label.text += player.last_move_notation
		
		
		if other.in_jaque == other.states_game.JAQUE:
			jugadas_label.text += "+"
			if other.ID_PLAYER == 1:
				lp1_turn.text = "¡EN JAQUE!"
				lp1_turn.add_theme_color_override("font_color", Color("db9100ff"))
				lp2_turn.text = "¡TU TURNO!"
				lp2_turn.add_theme_color_override("font_color", Color("ffffffff"))
			else:
				lp2_turn.text = "¡EN JAQUE!"
				lp2_turn.add_theme_color_override("font_color", Color("db9100ff"))
				lp1_turn.text = "¡TU TURNO!"
				lp1_turn.add_theme_color_override("font_color", Color("ffffffff"))
		elif other.in_jaquemate:
			jugadas_label.text += "#"
			if other.ID_PLAYER == 1:
				lp1_turn.text = "¡JAQUEMATE!"
				lp1_turn.add_theme_color_override("font_color", Color("#ff0000"))
				lp2_turn.text = "¡TU TURNO!"
				lp2_turn.add_theme_color_override("font_color", Color("ffffffff"))
			else:
				lp2_turn.text = "¡JAQUEMATE!"
				lp2_turn.add_theme_color_override("font_color", Color("#ff0000"))
				lp1_turn.text = "¡TU TURNO!"
				lp1_turn.add_theme_color_override("font_color", Color("ffffffff"))
		else:
			lp1_turn.text = "¡TU TURNO!"
			lp2_turn.text = "¡TU TURNO!"
			lp1_turn.add_theme_color_override("font_color", Color("ffffffff"))
			lp2_turn.add_theme_color_override("font_color", Color("ffffffff"))
		#CADENA DE JUGADAS
		jugadas_label.text += " | "
"""
estados especiales:
- jaquemate (sin movimientos disponibles)
- jaque (rey)

- tablas (rey/rey - movimientos repetidos)
"""
func process_jaquemate():
	var player = select_player_by_turn()
	
	var there_king = false
	for p in player.my_pieces:
		if p.select_type == 5:
			there_king = true
	
	if not there_king: player.in_jaquemate = true
	
	MainUI.set_cadena_won(jugadas_label.text)
	if player.in_jaquemate:
		MainUI.on_won()
		MainUI.set_text_won_menu("EL GANADOR ES: " + select_other_by_turn().player_name)
		won = true
	elif select_other_by_turn().in_jaquemate:
		MainUI.on_won()
		MainUI.set_text_won_menu("EL GANADOR ES: " + player.player_name)
		won = true

func process_draw() -> bool:
	var only_kings = true
	for p in players:
		if len(p.my_pieces) == 1:
			if p.my_pieces[0].select_type != 5: #king
				only_kings = false
		else: only_kings = false
		
	return only_kings

func _process(_delta: float) -> void:
	if not won:
		manager_turns()
	process_jaquemate()
	
	players[0].load_time(_delta, lp1_time)
	players[1].load_time(_delta, lp2_time)
