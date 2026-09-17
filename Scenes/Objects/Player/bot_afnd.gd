class_name Bot
extends ChessPlayer

@export var board_parent: Node2D
var board: Board
var board_points: PointChess

var bot_dificulty: int ## 0 Fácil · 1 Medio · 2 Difícil | -1 NA
enum states {THINKING, SEARCH, SELECT, END}
enum personalidades {DEFENDER, MOVIMIENTO, BLOQUEAR, ATACAR, RETIRAR}

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
	Piece.Type.King: 0.0,
}

func load_data():
	board = utils.obtener_nodos_por_tipo(self.chessBoard, Board)[0]
	board_points = utils.obtener_nodos_por_tipo(self.chessBoard, PointChess)[0]

	afnd = AFND.new()
	print("[BOT] todo cargado")

func restore():
	afnd.limpiar()
	mapa_movimientos.clear()
	actual_state = states.THINKING

# --- Se llama desde afuera (GameManager / Player) cuando el humano mueve ---
func registrar_movimiento_player(notacion: String) -> void:
	player_moves += "|" + notacion
	actualizar_emocion()

func actualizar_emocion() -> void:
	print("Mi emocion actual: ",emocion_actual)
	
	pass


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
			resultado.append({"clave": clave, "destino_id": destino_id, "peso": peso})
	return resultado

# --- Ponderación externa al AFND (tuya) ---
# Dejo un valor clásico de captura como base razonable por personalidad;
# ajustá esto con tu algoritmo real de ponderación.
func ponderar_movimiento(pieza: Piece, destino: Vector2i, emocion) -> float:
	match emocion:
		personalidades.ATACAR:
			print("Atacando")
			return valor_pieza_en(destino) * 10.0 + 1.0
		personalidades.DEFENDER:
			print("Defendiendo")
			# prioriza mover piezas de menor valor, mantenerse "atrás"
			return 10.0 - VALORES_PIEZA.get(pieza.select_type, 0.0)
		personalidades.BLOQUEAR:
			print("Bloqueando")
			return valor_pieza_en(destino) + 1.0
		personalidades.RETIRAR:
			print("Retirando")
			var dist_rey = abs(destino.y - my_king.actual_pos.y) + abs(destino.x - my_king.actual_pos.x)
			return -float(dist_rey)
		_: # MOVIMIENTO
			return valor_pieza_en(destino) + 1.0

func main():
	match actual_state:
		states.THINKING:
			#actualizar_emocion()
			pensar()
			actual_state = states.SELECT
		states.SELECT:
			ejecutar_mejor_jugada()
			actual_state = states.END
		states.END:
			actual_state = states.THINKING
			pass #restore() -> lo llama GameManager al cambiar de turno

func pensar() -> void:
	print("=====================================")
	#for i in self.danger_points:
	#	board_points.set_point(i, Vector2i(2,1))
		
	mapa_movimientos.clear()
	afnd.limpiar()
	afnd.establecer_inicial(ID_RAIZ)
	if afnd.first_call:
		afnd.set_first_move(ID_RAIZ, null, 10, generador_movimientos)
	else:
		afnd.construir_recursivo(ID_RAIZ, null, 10, generador_movimientos)

func ejecutar_mejor_jugada() -> void:
	var mejor_clave = afnd.elegir_mejor_camino()
	if mejor_clave == null:
		self.in_jaquemate = true
		return

	var info = mapa_movimientos.get(mejor_clave, null)
	if info == null:
		print("[BOT] No se encontró el movimiento para la clave: ", mejor_clave)
		return
	
	await get_tree().create_timer(1.0).timeout
	print("[BOT] Mejor clave: ", mejor_clave)
	selected_piece = info["pieza"].actual_pos
	move_piece(board, info["destino"])
