class_name Bot
extends ChessPlayer

@export var board_parent: Node2D
var board: Board

var bot_dificulty: int ## 0 Fácil · 1 Medio · 2 Difícil | -1 NA
enum states {THINKING, END}
var actual_state = states.THINKING

func load_data():
	board = utils.obtener_nodos_por_tipo(self.chessBoard, Board)[0]
	print("[BOT] todo cargado")

func restore():
	pass
	
func main():
	match actual_state:
		states.THINKING:
			print("[BOT] pensando respuesta...")
		states.END:
			pass#restore()
	
