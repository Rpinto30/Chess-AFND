class_name AFND
extends RefCounted

class Estado:
	var id
	var peso: float
	var transiciones: Dictionary = {}  # clave (cualquier tipo) -> Estado

	func _init(id_, peso_: float = 0.0) -> void:
		id = id_
		peso = peso_


var estados: Dictionary = {}  # id -> Estado
var estado_inicial_id

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
	return estados.get(id, null) #Devuelve el estado con el ID especificado, o null si no existe

func limpiar() -> void:
	estados.clear()
	estado_inicial_id = null


func construir_recursivo(id_actual, id_prev, limit: int, generador: Callable) -> void:
	if id_actual == id_prev or limit <= 0:
		return

	var posibles: Array = generador.call(id_actual)
	for paso in posibles:
		var clave = paso["clave"]
		var destino_id = paso["destino_id"]
		var peso = paso.get("peso", 0.0)

		agregar_transicion(id_actual, clave, destino_id, peso)
		construir_recursivo(destino_id, id_actual, limit - 1, generador)



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

	return mejor_clave
