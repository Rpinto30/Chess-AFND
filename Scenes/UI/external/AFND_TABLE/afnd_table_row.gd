extends PanelContainer
## Una sola fila de la tabla del AFND. La crea y la llena afnd_table.gd.

@onready var paso_label: Label = %PasoLabel
@onready var estado_label: Label = %EstadoLabel
@onready var lee_label: Label = %LeeLabel
@onready var transicion_label: Label = %TransicionLabel
@onready var nuevo_estado_label: Label = %NuevoEstadoLabel
@onready var explicacion_label: Label = %ExplicacionLabel

const COLOR_VALID := Color(0.2, 0.55, 0.25, 1) # mismo verde que el tablero

var _step: int = 0
var _base_color: Color = Color(0.13, 0.10, 0.07, 1)
var _is_valid: bool = false


func set_data(step: int, estado_actual: String, simbolo: String, transicion: String, nuevo_estado: String, explicacion: String) -> void:
	_step = step
	estado_label.text = estado_actual
	lee_label.text = simbolo
	transicion_label.text = transicion
	nuevo_estado_label.text = nuevo_estado
	explicacion_label.text = explicacion
	_refresh_paso_label()


## Color de "cebra" (filas pares/impares) — se ignora mientras la fila
## esté marcada como válida.
func set_stripe_color(color: Color) -> void:
	_base_color = color
	if not _is_valid:
		_apply_color(_base_color)


## Pinta la fila de verde (o la regresa a su color normal).
func set_valid(valid: bool) -> void:
	_is_valid = valid
	_apply_color(COLOR_VALID if valid else _base_color)
	_refresh_paso_label()


func _refresh_paso_label() -> void:
	paso_label.text = ("⊛ " if _is_valid else "") + str(_step)


func _apply_color(color: Color) -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.content_margin_left = 6
	style.content_margin_right = 6
	style.content_margin_top = 5
	style.content_margin_bottom = 5
	add_theme_stylebox_override("panel", style)
