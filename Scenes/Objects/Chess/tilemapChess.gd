class_name Board
extends TileMapLayer

@export var points: TileMapLayer 
@export_category("NORMAL STYLE")
@export var blackPieces: Array[Texture2D]
@export var whitePieces: Array[Texture2D]
@export_category("AMBIENT STYLE")
@export var blackPieces_AMBIENT: Array[Texture2D]
@export var whitePieces_AMBIENT: Array[Texture2D]
@export var piece: PackedScene
signal touched(t: bool, pos: Vector2i)

const SIZE: Vector2i = Vector2i(8,8)
var matrixPos = []
var matrixRef = []

func _ready():
	for i in range(SIZE.x):
		var nref = []
		nref.resize(SIZE.y)
		nref.fill("")
		matrixRef.append(nref)
		matrixPos.append([])
		for j in range(SIZE.y):
			set_cell(Vector2i(i,j), 0, Vector2i((i+j)%2,0))
			matrixPos[-1].append(0)
			
#INSTANCIA DE OBJETOS
#typeColor: 0:white| 1:black
#typePiece: 0:Pawn| 1:knight| 2:bishop| 3:rook| 4:queen| 5:king
#style: 0:classic| 1: ambient
func instancePiece(pos: Vector2i, typeColor: int, typePiece: int, style: int = 0) -> Node2D:
	var instance = piece.instantiate()
	#CONFIG
	var sprite = utils.obtener_nodos_por_tipo(instance, Sprite2D)[0]
	instance.global_position = pos
	instance.scale = Vector2(1,1) * 1.7
	instance.select_type = typePiece
	instance.color = typeColor
	if typeColor == 0: # White
		if style == 0: #classic
			sprite.texture = whitePieces[typePiece]
		else:	
			sprite.texture = whitePieces_AMBIENT[typePiece]
	else: # Black
		if style == 0: #classic
			sprite.texture = blackPieces[typePiece]
		else:	
			sprite.texture = blackPieces_AMBIENT[typePiece]
	
	get_tree().current_scene.add_child(instance)
	return instance

#MANEJO DE TOQUES
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch and event.pressed:
		_manejar_toque(event.position)
	elif event is InputEventScreenDrag:
		pass
		#_manejar_toque(event.position)
	else:
		touched.emit(false, Vector2i(-1,-1))

func _manejar_toque(posicion_pantalla: Vector2):
	var posicion_mundo = get_canvas_transform().affine_inverse() * posicion_pantalla
	var posicion_local = to_local(posicion_mundo)
	var coordenada_celda = local_to_map(posicion_local)
	
	
	var centro_local = map_to_local(coordenada_celda)
	var centro_mundo = to_global(centro_local)
	
	# print("Celda tocada: ", coordenada_celda)

	var tile_data = get_cell_tile_data(coordenada_celda)
	if tile_data:
		#print("Selection: ", coordenada_celda)
		touched.emit(true, coordenada_celda)
		return [coordenada_celda, centro_mundo]
	else:
		#print("La celda está vacía.")
		touched.emit(true, Vector2i(-1,-1))
		return [Vector2i(-1,-1), centro_mundo]
