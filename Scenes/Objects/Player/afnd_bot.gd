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
func _init(UI:PRINCIPALMENU) -> void:
	mainUI = UI

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
	if id_actual == id_prev or limit <= 0:
		return

	var posibles: Array = generador.call(id_actual)
	if posibles.is_empty():
		first_call = false
		return

	var nombre_actual = obtener_nombre_q(id_actual)

	for paso in posibles:
		var clave = paso["clave"]
		var destino_id = paso["destino_id"]
		var peso = paso.get("peso", 0.0)

		agregar_transicion(id_actual, clave, destino_id, peso)

		var nombre_destino = obtener_nombre_q(destino_id)
		var move_con_peso = "%s (%.1f)" % [clave, peso]

		var transiciones_fila = [{"state": nombre_destino, "move": move_con_peso}]

		var paso_num = mainUI.afnd_add_instruction(nombre_actual, clave, transiciones_fila)

		if clave.find("#") != -1:
			mainUI.afnd_mark_state_valid(paso_num)

		construir_recursivo(destino_id, id_actual, limit - 1, generador)

	first_call = false

func sumar_rama(id) -> float:
	var estado = obtener_estado(id)
	if estado == null:
		return 0.0
	var total = estado.peso
	for clave in estado.transiciones:
		total += sumar_rama(estado.transiciones[clave].id)
	return total



func elegir_mejor_camino(id_desde = null) -> Variant:
	var desde = id_desde if id_desde != null else estado_inicial_id #Comenzamos desde el estado inicial si no se especifica otro
	var estado = obtener_estado(desde)
	print("ELIGIENDO")
	if estado == null or estado.transiciones.is_empty():#Si no hay transiciones, no hay camino que elegir
		return null
	
	var puntajes: Dictionary = {}
	for clave in estado.transiciones:
		puntajes[clave] = sumar_rama(estado.transiciones[clave].id) #Calculamos el puntaje total de cada camino posible desde el estado actual

	var mejor_clave = null
	var mejor_puntaje = -INF
	for clave in puntajes:
		if puntajes[clave] > mejor_puntaje:
			mejor_puntaje = puntajes[clave]
			mejor_clave = clave
	print(mejor_clave)
	return mejor_clave
