class_name AFND
extends RefCounted

class Estado:
	var id
	var peso: float
	var transiciones: Dictionary = {}  # clave (cualquier tipo) -> Estado

	func _init(id_, peso_: float = 0.0) -> void:
		id = id_
		peso = peso_

var first_call: bool = true
var estados: Dictionary = {}  # id -> Estado
var estado_inicial_id

var contador_q: int = 0
var nombres_q: Dictionary = {} 

func obtener_nombre_q(id) -> String:
	if nombres_q.has(id):
		return nombres_q[id]
	var nombre = "q%d" % contador_q
	nombres_q[id] = nombre
	contador_q += 1
	return nombre

func iniciar_tabla_afnd(id_raiz) -> void:
	mainUI.afnd_clear_table()
	contador_q = 0
	nombres_q.clear()
	obtener_nombre_q(id_raiz)  # fuerza que la raíz sea q0
	mainUI.set_afnd_current_string("")  # o la cadena que corresponda


var mainUI: PRINCIPALMENU
var board: Board
var bot:Bot
func _init(UI:PRINCIPALMENU, _board:Board, bot_:Bot) -> void:
	mainUI = UI
	self.board = _board
	self.bot = bot_

func agregar_estado(id, peso: float = 0.0) -> Estado:
	if estados.has(id):
		return estados[id]
	var nuevo = Estado.new(id, peso)
	estados[id] = nuevo
	return nuevo

func agregar_transicion(id_origen, clave, id_destino, peso_destino: float = 0.0) -> void:
	var origen = agregar_estado(id_origen)
	agregar_estado(id_destino, peso_destino)
	origen.transiciones[clave] = estados[id_destino]

func establecer_inicial(id) -> void:
	estado_inicial_id = id
	agregar_estado(id)

func obtener_estado(id) -> Estado:
	return estados.get(id, null) 

func limpiar() -> void:
	estados.clear()
	estado_inicial_id = null

func set_first_move(id_actual, limit: int, generador: Callable) -> void:
	var posibles: Array = generador.call(id_actual)
	var p = posibles.pick_random()
	if p:
		print("ALEATORIO")
		var clave = p["clave"]
		var destino_id = p["destino_id"]
		var peso = p.get("peso", 0.0)

		agregar_transicion(id_actual, clave, destino_id, peso)

		var nombre_actual = obtener_nombre_q(id_actual)
		var nombre_destino = obtener_nombre_q(destino_id)
		var move_con_peso = "%s (%.1f)" % [clave, peso]

		var paso_num = mainUI.afnd_add_instruction(nombre_actual, clave, [{"state": nombre_destino, "move": move_con_peso}])

		if clave.find("#") != -1:
			mainUI.afnd_mark_state_valid(paso_num)

		construir_recursivo(destino_id, id_actual, limit - 1, generador)
		return

func construir_recursivo(id_actual, id_prev, limit: int, generador: Callable) -> void:
	if limit <= 0:
		return  # tope de profundidad, no es un caso de aceptación

	var nombre_actual = obtener_nombre_q(id_actual)
	var posibles: Array = generador.call(id_actual)

	if posibles.is_empty():
		# CASO DE ACEPTACIÓN: la pieza/estado ya no tiene movimientos.
		# Se representa como si leyera "/" y no tiene transiciones.
		var paso_num = mainUI.afnd_add_instruction(
			nombre_actual, "/", [], "Sin más movimientos posibles, cadena aceptada"
		)
		mainUI.afnd_mark_state_valid(paso_num)
		first_call = false
		return
	for paso in posibles:
		var clave = paso["clave"]
		var destino_id = paso["destino_id"]
		var peso = paso.get("peso", 0.0)
		var pieza_paso: Piece = paso["pieza"]#ete
		var destino_paso: Vector2i = paso["destino_pos"]

		agregar_transicion(id_actual, clave, destino_id, peso)
		
		
		var nombre_destino = obtener_nombre_q(destino_id)
		var move_con_peso = "%s (%.1f)" % [clave, peso]
		var paso_num = mainUI.afnd_add_instruction(nombre_actual, clave, [{"state": nombre_destino, "move": move_con_peso}])
		bot.moves_str += clave + '|'
		if clave.find("#") != -1:
			mainUI.afnd_mark_state_valid(paso_num)
			continue  # también aceptación por jaque mate real, no seguimos esta rama

		var snap = bot._simular_movimiento(pieza_paso, destino_paso)
		construir_recursivo(destino_id, id_actual, limit - 1, generador)
		bot._deshacer_movimiento(snap)

	first_call = false

func mejor_rama(id) -> float:
	var estado = obtener_estado(id)
	if estado == null:
		return 0.0
	if estado.transiciones.is_empty():
		return estado.peso

	var mejor = -INF
	for clave in estado.transiciones:
		var v = mejor_rama(estado.transiciones[clave].id)
		if v > mejor:
			mejor = v
	return estado.peso + mejor

func sumar_rama(id) -> float:
	var estado = obtener_estado(id)
	if estado == null:
		return 0.0
	var total = estado.peso
	for clave in estado.transiciones:
		total += sumar_rama(estado.transiciones[clave].id)
	return total



func elegir_mejor_camino(id_desde = null) -> Variant:
	var desde = id_desde if id_desde != null else estado_inicial_id
	var estado = obtener_estado(desde)
	if estado == null or estado.transiciones.is_empty():
		return null

	var puntajes: Dictionary = {}
	for clave in estado.transiciones:
		puntajes[clave] = mejor_rama(estado.transiciones[clave].id)

	var mejor_puntaje = -INF
	for clave in puntajes:
		if puntajes[clave] > mejor_puntaje:
			mejor_puntaje = puntajes[clave]

	var mejores_claves = []
	for clave in puntajes:
		if puntajes[clave] == mejor_puntaje:
			mejores_claves.append(clave)

	return mejores_claves.pick_random()
