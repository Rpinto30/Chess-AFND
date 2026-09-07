extends TileMapLayer

@export var points: TileMapLayer 
@export var piece: PackedScene

const SIZE: Vector2i = Vector2i(8,8)
var matrixPos = []
var matrixRef = []

func _ready():
	for i in range(SIZE.x):
		matrixPos.append([])
		matrixRef.append([].resize(SIZE.y))
		for j in range(SIZE.y):
			set_cell(Vector2i(i,j), 0, Vector2i((i+j)%2,0))
			matrixPos[-1].append(0)
			


#INSTANCIA DE OBJETOS
func instancePiece(pos: Vector2) -> void:
	pass
	#var instance = piece.instantiate()
	#instance.global_position = pos
	#get_tree().current_scene.add_child(instance)
	

#MANEJO DE TOQUES
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch and event.pressed:
		_manejar_toque(event.position)
		#points.set_cell(pos[0], 0, Vector2i(2,0))
	elif event is InputEventScreenDrag:
		_manejar_toque(event.position)

func _manejar_toque(posicion_pantalla: Vector2):
	var posicion_mundo = get_canvas_transform().affine_inverse() * posicion_pantalla
	var posicion_local = to_local(posicion_mundo)
	var coordenada_celda = local_to_map(posicion_local)
	
	
	var centro_local = map_to_local(coordenada_celda)
	var centro_mundo = to_global(centro_local)
	
	# print("Celda tocada: ", coordenada_celda)

	var tile_data = get_cell_tile_data(coordenada_celda)
	if tile_data:
		print("Selection: ", coordenada_celda)
		return [coordenada_celda, centro_mundo]
	else:
		print("La celda está vacía.")
		return [Vector2i(-1,-1), centro_mundo]
