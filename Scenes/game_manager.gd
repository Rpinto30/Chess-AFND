class_name GameManager
extends Node2D
#====================GLOBAL REFERENCE======================
@export var board_parent: Node2D
var board: Board
@export var label: Label

#=======================GAME CONTROL=======================
enum turns {P1, P2}
@export var turn = turns.P1
var players: Array
var bot = null

func _ready() -> void:
	players = utils.obtener_nodos_por_tipo(self, ChessPlayer).slice(0,2)
	board = utils.obtener_nodos_por_tipo(board_parent, Board)[0]
	for i in players:
		if i.type_color_player == ChessPlayer.color_player.WHITE:
			set_pieces(i, 1)
			i.ID_PLAYER = 1
		else: 
			set_pieces(i, 2)
			i.ID_PLAYER = 2
	print(board.matrixPos)
	print(board.matrixRef)

func set_pieces(player: ChessPlayer, color: int):
	var line = board.SIZE.x - 1 if color == 1 else 0 
	for y in player.init_pos_pieces:
		for x in range(len(y)):
			print(y[x])
			print(player.type_color_player)
			var pos_local = board.map_to_local(Vector2i(x, line))
			var pos_global = board.to_global(pos_local)
			
			var piece = board.instancePiece(
				pos_global,
				player.type_color_player,
				y[x],
			)
						
			board.matrixPos[line][x] = color 
			board.matrixRef[line][x] =  piece
			
		line = line - 1 if color == 1 else line + 1


func manager_turns():
	var player: Player
	if turn == turns.P1:
		player = players[0]
		label.text = "Turno de las blancas"
	else:
		player = players[1]
		label.text = "Turno de las negras"
	player.main()
	if player.actual_state == player.states.END:
		if turn == turns.P1:  turn = turns.P2
		else: turn = turns.P1
		player.restore()

func _process(_delta: float) -> void:
	manager_turns()
	
	
	
