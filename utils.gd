class_name utils
extends RefCounted  

static func obtener_nodos_por_tipo(nodo_raiz: Node, tipo_clase) -> Array:
	var resultado: Array = []
	for hijo in nodo_raiz.get_children():
		if is_instance_of(hijo, tipo_clase):
			resultado.append(hijo)
		resultado.append_array(obtener_nodos_por_tipo(hijo, tipo_clase))
	return resultado

static func obtener_nodos_por_nombre(nodo_raiz: Node, name) -> Array:
	var resultado: Array = []
	for hijo in nodo_raiz.get_children():
		if hijo.name == name:
			resultado.append(hijo)
		resultado.append_array(obtener_nodos_por_nombre(hijo, name))
	return resultado



const PREFIJOS_NOTACION = {
	Piece.Type.Pawn: "",
	Piece.Type.Knightm: "C",
	Piece.Type.Bishop: "A",
	Piece.Type.Rook: "T",
	Piece.Type.Queen: "D",
	Piece.Type.King: "R",
}

static func get_piece_value(type: int):
	match type:
		Piece.Type.Pawn: 
			return 0
		Piece.Type.Knightm: 
			return 2
		Piece.Type.Bishop:
			return 2
		Piece.Type.Rook: 
			return 4
		Piece.Type.Queen: 
			return 8
		_:
			return -1


static func set_notation(pieza: Piece, destino: Vector2i, 
kill_piece: bool = false, 
in_jaque:bool = false, 
in_jaque_mate:bool = false) -> String:
	var letras = "abcdefgh"
	var letra = letras[destino.x] if destino.x < letras.length() else "?"
	if kill_piece:
		letra += 'x'
	var numero = destino.y 
	var prefijo = PREFIJOS_NOTACION.get(pieza.select_type, "")
	var r = prefijo + letra + str(numero)
	if in_jaque:
		r += '+'
	elif in_jaque_mate:
		r += '#'
	return r


static func formatear_tiempo(segundos_totales: float) -> String:
	# 1. Pasamos a entero para evitar problemas con los decimales
	var segundos_enteros: int = int(segundos_totales)
	
	# 2. Calculamos minutos y segundos
	@warning_ignore("integer_division")
	var minutos: int = segundos_enteros / 60
	var segundos: int = segundos_enteros % 60
	
	return "%02d:%02d" % [minutos, segundos]

static func check_operation_vec_player(ID_PLAYER: int, piece_pos:Vector2i, combination:Vector2i):
	if ID_PLAYER == 1:
		return Vector2i(piece_pos.x+combination.x, piece_pos.y-combination.y)
	else:
		return Vector2i(piece_pos.x+combination.x, piece_pos.y+combination.y)
	#return piece_pos-combination if ID_PLAYER == 1 else piece_pos+combination

static func flip_y_axis(ID_PLAYER: int, vector: Vector2i):
	return vector*Vector2i(1,-1) if ID_PLAYER == 1 else vector*Vector2i(1,1)

static func transition_scene(path: String) -> void:
	SceneTransition.transition_to_scene(path)

static func reveal_scene() -> void:
	SceneTransition.play_wipe_out()
