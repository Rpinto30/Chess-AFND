class_name utils
extends RefCounted  

static func obtener_nodos_por_tipo(nodo_raiz: Node, tipo_clase) -> Array:
	var resultado: Array = []
	for hijo in nodo_raiz.get_children():
		if is_instance_of(hijo, tipo_clase):
			resultado.append(hijo)
		resultado.append_array(obtener_nodos_por_tipo(hijo, tipo_clase))
	return resultado

static func check_operation_vec_player(ID_PLAYER: int, piece_pos:Vector2i, combination:Vector2i):
	return piece_pos-combination if ID_PLAYER == 1 else piece_pos+combination

static func transition_scene(path: String) -> void:
	SceneTransition.transition_to_scene(path)

static func reveal_scene() -> void:
	SceneTransition.play_wipe_out()
