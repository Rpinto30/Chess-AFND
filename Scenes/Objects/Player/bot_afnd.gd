class_name Bot
extends ChessPlayer

@export var board_parent: Node2D
var board: Board
var board_points: PointChess
var mainUI: PRINCIPALMENU

var bot_dificulty: int ## 0 Fácil · 1 Medio · 2 Difícil | -1 NA
enum states {THINKING, SEARCH, SELECT, VALIDMODE, END}
enum personalidades {DEFENDER, MOVIMIENTO, BLOQUEAR, ATACAR, RETIRAR}

var debug_personalidades = [
	"DEFENDIENDO",
	"MOVIMIENTO",
	"BLOQUEANDO",
	"ATACANDO",
	"RETIRADA"
]

var actual_state = states.THINKING
var emocion_actual = personalidades.MOVIMIENTO

var afnd: AFND
var player_moves: String = ""


const ID_RAIZ = "e"

# clave (String de notación) -> {"pieza": Piece, "destino": Vector2i}
# Se reconstruye cada vez que pensamos, para poder traducir la clave
# ganadora del AFND de vuelta a un movimiento ejecutable.
var mapa_movimientos: Dictionary = {}

const VALORES_PIEZA = {
	Piece.Type.Pawn: 1.0,
	Piece.Type.Knightm: 3.0,
	Piece.Type.Bishop: 3.0,
	Piece.Type.Rook: 5.0,
	Piece.Type.Queen: 9.0,
	Piece.Type.King: -1.0,
}

func load_data():
	board = utils.obtener_nodos_por_tipo(self.chessBoard, Board)[0]
	board_points = utils.obtener_nodos_por_tipo(self.chessBoard, PointChess)[0]
	board_points_extra = utils.obtener_nodos_por_tipo(self.chessBoard, PointExtraChess)[0]
	mainUI = utils.obtener_nodos_por_tipo(self.get_parent(), PRINCIPALMENU)[0]
	
	afnd = AFND.new(mainUI, board, self)
	print("[BOT] todo cargado")

func restore():
	afnd.limpiar()
	mapa_movimientos.clear()
	actual_state = states.THINKING

# --- Se llama desde afuera (GameManager / Player) cuando el humano mueve ---
func registrar_movimiento_player(notacion: String) -> void:
	player_moves += "|" + notacion
	actualizar_emocion()


func my_pieces_in_danger_type():
	var r = []
	var n = 0
	for p in self.my_pieces:
		if p.actual_pos in self.danger_points: 
			#board_points.set_point(p.actual_pos, Vector2i(2,1))
			r.append(p.select_type)
			n += 1
	return [r, n]

func get_avg_pos_y_pieces():
	var n = 0
	var y = 0
	if len(self.my_pieces) > 0:
		for p in self.my_pieces:
			y += p.actual_pos.y
			n+=1
		return int(y/n)
	else: return 0
	
#EMOCIONES
func actualizar_emocion() -> void:
	print("Mi emocion actual: ", debug_personalidades[emocion_actual])
	if self.in_jaque: 
		self.emocion_actual = self.personalidades.BLOQUEAR
	else:
		var rng_block = RandomNumberGenerator.new()
		var last_move = player_moves.split('|')[-1]
		var pieces_in_danger = my_pieces_in_danger_type()
		var avg_pos_y = get_avg_pos_y_pieces() 
		
		print("LOS MOVIMIENTOS DEL JUGADOR: ",player_moves)
		
		if len(self.my_pieces) < rng_block.randi_range(5, 10) or (
			last_move.contains('x') and [true, false].pick_random()
		):
			self.emocion_actual = self.personalidades.RETIRAR 
		
		if pieces_in_danger[1] > len(my_pieces) * 0.4:
			if rng_block.randi_range(0, 1) == 0:
				self.emocion_actual = self.personalidades.BLOQUEAR 
			else:
				self.emocion_actual = self.personalidades.ATACAR 

		print(pieces_in_danger[0].slice(0,3), pieces_in_danger[1])
		print(avg_pos_y)
		if avg_pos_y < rng_block.randi_range(2, 6) and(
			 pieces_in_danger[1] > 2
		) :
			self.emocion_actual = self.personalidades.ATACAR 

func valor_pieza_en(pos: Vector2i) -> float:
	if not Piece.filt_pos_limits(pos, board):
		return 0.0
	var objetivo = board.matrixRef[pos.y][pos.x]
	if is_instance_of(objetivo, Piece):
		return VALORES_PIEZA.get(objetivo.select_type, 0.0)
	return 0.0

func generador_movimientos(id_actual) -> Array:
	var resultado: Array = []
	if id_actual != ID_RAIZ:
		return resultado

	for pieza in self.my_pieces:
		var combos = pieza.get_my_valid_moves(pieza.actual_pos, board, self) if not self.in_jaque else (
			self.valid_moves_jaque(board, pieza)
		)
		var destinos = pieza.get_possible_moves(self, pieza.actual_pos, board, combos)
		#valid_moves_jaque
		for destino in destinos:
			var clave = utils.set_notation(pieza, destino)
			var destino_id = "%s#%d" % [clave, pieza.get_instance_id()]
			var peso = ponderar_movimiento(pieza, destino, emocion_actual)

			mapa_movimientos[clave] = {"pieza": pieza, "destino": destino}
			resultado.append({
	"clave": clave,
	"destino_id": destino_id,
	"peso": peso,
	"pieza": pieza,          # <-- ¿está esta línea?
	"destino_pos": destino   # <-- ¿está esta línea?
})
	return resultado

# --- Ponderación externa al AFND (tuya) ---
# Dejo un valor clásico de captura como base razonable por personalidad;
# ajustá esto con tu algoritmo real de ponderación.
func ponderar_movimiento(pieza: Piece, destino: Vector2i, emocion) -> float:
	match emocion:
		personalidades.ATACAR:
			return valor_pieza_en(destino) * 5.0 + 1.0 + penalizacion_peligro(destino, pieza)
		personalidades.DEFENDER:
			return 10.0 - VALORES_PIEZA.get(pieza.select_type, 0.0) + penalizacion_peligro(destino, pieza)
		personalidades.BLOQUEAR:
			return valor_pieza_en(destino) + 1.0 + penalizacion_peligro(destino, pieza)
		personalidades.RETIRAR:
			var dist_rey = abs(destino.y - my_king.actual_pos.y) + abs(destino.x - my_king.actual_pos.x)
			return -float(dist_rey)
		_: # MOVIMIENTO
			return (valor_pieza_en(destino) + 1.0 
				+ bonus_centralidad(destino) 
				+ bonus_desarrollo(pieza) 
				+ penalizacion_peligro(destino, pieza))

func main():
	match actual_state:
		states.THINKING:
			#actualizar_emocion()
			mainUI.afnd_clear_table()
			pensar()
			actual_state = states.SELECT
		states.SELECT:
			ejecutar_mejor_jugada()
			actual_state = states.VALIDMODE
		states.END:
			pass#actual_state = states.THINKING
			#restore() -> lo llama GameManager al cambiar de turno

var moves_str = ''
func pensar() -> void:
	moves_str = ''
	print("=====================================")
	#for i in self.danger_points:
	#	board_points.set_point(i, Vector2i(2,1))
		
	mapa_movimientos.clear()
	afnd.limpiar()
	afnd.establecer_inicial(ID_RAIZ)
	if afnd.first_call:
		afnd.set_first_move(ID_RAIZ, 10, generador_movimientos)
	else:
		afnd.construir_recursivo(ID_RAIZ, null, 10, generador_movimientos)
	mainUI.set_afnd_current_string(moves_str)
	
func ejecutar_mejor_jugada() -> void:
	var mejor_clave = afnd.elegir_mejor_camino()
	if mejor_clave == null:
		self.in_jaquemate = true
		return

	var info = mapa_movimientos.get(mejor_clave, null)
	if info == null:
		print("[BOT] No se encontró el movimiento para la clave: ", mejor_clave)
		return
	var rng_block = RandomNumberGenerator.new()
	#await get_tree().create_timer(5, false).timeout
	print("[BOT] Mejor clave: ", mejor_clave)
	selected_piece = info["pieza"].actual_pos
	await get_tree().create_timer(rng_block.randf_range(0.5,4.3)).timeout
	move_piece(board, info["destino"])
	actual_state = states.END
	

func _simular_movimiento(pieza: Piece, destino: Vector2i) -> Dictionary:
	var origen = pieza.actual_pos
	var id_owner = board.matrixPos[origen.y][origen.x]

	var pieza_capturada = null
	var capturada_en_my_pieces = false
	var target = board.matrixRef[destino.y][destino.x]
	if is_instance_of(target, Piece):
		pieza_capturada = target
		if pieza_capturada in self.my_pieces:
			capturada_en_my_pieces = true
			self.my_pieces.erase(pieza_capturada)

	board.matrixRef[destino.y][destino.x] = pieza
	board.matrixRef[origen.y][origen.x] = ""
	board.matrixPos[destino.y][destino.x] = id_owner
	board.matrixPos[origen.y][origen.x] = 0

	pieza.actual_pos = destino

	return {
		"pieza": pieza,
		"origen": origen,
		"destino": destino,
		"id_owner": id_owner,
		"capturada": pieza_capturada,
		"capturada_en_my_pieces": capturada_en_my_pieces
	}


func _deshacer_movimiento(snap: Dictionary) -> void:
	var pieza = snap["pieza"]
	var origen = snap["origen"]
	var destino = snap["destino"]

	board.matrixRef[origen.y][origen.x] = pieza
	board.matrixPos[origen.y][origen.x] = snap["id_owner"]
	pieza.actual_pos = origen

	if snap["capturada"] != null:
		board.matrixRef[destino.y][destino.x] = snap["capturada"]
		board.matrixPos[destino.y][destino.x] = snap["capturada"].player_owner.ID_PLAYER
		if snap["capturada_en_my_pieces"]:
			self.my_pieces.append(snap["capturada"])
	else:
		board.matrixRef[destino.y][destino.x] = ""
		board.matrixPos[destino.y][destino.x] = 0



const CENTRO = [Vector2i(3,3), Vector2i(3,4), Vector2i(4,3), Vector2i(4,4)]

func bonus_centralidad(pos: Vector2i) -> float:
	var dist_min = 99
	for c in CENTRO:
		var d = abs(pos.x - c.x) + abs(pos.y - c.y)
		if d < dist_min:
			dist_min = d
	# entre más cerca del centro, más puntos (máximo ~0.6, mínimo 0)
	return max(0.0, 0.6 - dist_min * 0.1)

func bonus_desarrollo(pieza: Piece) -> float:
	# premia sacar piezas menores que no se han movido (desarrollo de apertura)
	if pieza.is_first_move and pieza.select_type in [Piece.Type.Knightm, Piece.Type.Bishop]:
		return 0.4
	return 0.0

func penalizacion_peligro(destino: Vector2i, pieza: Piece) -> float:
	# evita mandar la pieza a una casilla atacada, salvo que sea un buen cambio
	if destino in self.danger_points:
		return -VALORES_PIEZA.get(pieza.select_type, 0.0) * 0.5
	return 0.0
