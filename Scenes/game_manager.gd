extends Node2D


@export var board_parent: Node2D
var board: Board

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	board = obtener_nodos_por_tipo(board_parent, Board)[0]
	var players = obtener_nodos_por_tipo(self, ChessPlayer).slice(0,2)
	for i in players:
		if i.type_color_player == ChessPlayer.color_player.WHITE:
			set_pieces(i, 1)
		else: set_pieces(i, 2)
	for a in board.matrixRef:
		for b in a:
			if is_instance_of(b, Object):
				print(b.list_data[b.select_type])
		
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func set_pieces(player: ChessPlayer, color: int):
	var line = board.SIZE.x - 1 if color == 1 else 0 
	for y in player.init_pos_pieces:
		for x in range(len(y)):			
			var pos_local = board.map_to_local(Vector2i(x, line))
			var pos_global = board.to_global(pos_local)
			
			var piece = board.instancePiece(pos_global)
			board.matrixPos[line][x] = color 
			board.matrixRef[line][x] =  piece
			
		line = line - 1 if color == 1 else line + 1
	
func obtener_nodos_por_tipo(nodo_raiz: Node, tipo_clase) -> Array:
	var resultado: Array = []
	for hijo in nodo_raiz.get_children():
		if is_instance_of(hijo, tipo_clase):
			resultado.append(hijo)
		resultado.append_array(obtener_nodos_por_tipo(hijo, tipo_clase))
	return resultado
