extends PopupPanel
## Tabla del AFND que valida el jaque mate en la cadena de movimientos.
## Se alimenta 100% por código (por ejemplo desde el script que ejecuta
## el autómata en cada movimiento). No tiene botones de "Limpiar" /
## "Agregar" / "Comprobar" en la interfaz: son las 3 funciones públicas
## de abajo, para que las llames tú cuando el AFND procese cada símbolo.

signal minimized

@onready var current_string_label: Label = %CurrentStringLabel
@onready var minimize_button: Button = %MinimizeButton
@onready var header_panel: PanelContainer = %HeaderPanel
@onready var rows_container: VBoxContainer = %RowsContainer

@export var _row_scene: PackedScene# = preload("res://afnd_table_row.tscn")
var _step_counter: int = 0
var _rows: Array[Control] = []

const COLOR_EVEN := Color(0.13, 0.10, 0.07, 1)
const COLOR_ODD := Color(0.09, 0.07, 0.05, 1)


func _ready() -> void:
	minimize_button.pressed.connect(_on_minimize_pressed)
	add_to_group("afnd_table")
	_apply_theme()


func _on_minimize_pressed() -> void:
	hide()
	minimized.emit()


func _apply_theme() -> void:
	var bg_style := StyleBoxFlat.new()
	bg_style.bg_color = Color(0.09, 0.07, 0.05, 1)
	bg_style.border_color = Color(0.55, 0.45, 0.2, 1)
	bg_style.set_border_width_all(2)
	bg_style.set_corner_radius_all(6)
	add_theme_stylebox_override("panel", bg_style)

	var header_style := StyleBoxFlat.new()
	header_style.bg_color = Color(0.17, 0.12, 0.07, 1)
	header_style.content_margin_left = 6
	header_style.content_margin_right = 6
	header_style.content_margin_top = 6
	header_style.content_margin_bottom = 6
	header_style.border_color = Color(0.55, 0.45, 0.2, 1)
	header_style.border_width_bottom = 2
	header_panel.add_theme_stylebox_override("panel", header_style)


# --------------------------------------------------------------------
# Espacio superior: cadena que está evaluando el AFND en este momento.
# --------------------------------------------------------------------

func set_current_string(cadena: String) -> void:
	current_string_label.text = cadena


# --------------------------------------------------------------------
# 1) Limpiarla
# --------------------------------------------------------------------
func clear_table() -> void:
	for row in _rows:
		row.queue_free()
	_rows.clear()
	_step_counter = 0


# --------------------------------------------------------------------
# 2) Agregar instrucción
# --------------------------------------------------------------------
## estado_actual: ej. "q2500"
## simbolo: el "carácter" que lee el autómata, es decir, el movimiento
##          completo (ej. "Cc3").
## transiciones: Array de diccionarios {"state": "q1", "move": "Ca4"},
##               una entrada por cada estado al que se puede llegar
##               (recuerda que al ser AFND puede haber varias).
## explicacion: opcional. Si no la mandas, se genera sola con el formato
##              "La pieza puede moverse a {q1 = Ca4, q2 = Ce5, ...}".
## Devuelve el número de "paso" de la fila creada — guárdalo si luego
## vas a llamar mark_state_valid() sobre esta misma fila.
func add_instruction(estado_actual: String, simbolo: String, transiciones: Array, explicacion: String = "") -> int:
	var step := _step_counter
	_step_counter += 1

	var states_list := PackedStringArray()
	var states_with_moves := PackedStringArray()
	for t in transiciones:
		states_list.append(str(t.get("state", "")))
		states_with_moves.append("%s = %s" % [t.get("state", ""), t.get("move", "")])

	var transicion_text := "δ(%s, '%s') = {%s}" % [estado_actual, simbolo, ", ".join(states_list)]
	var nuevo_estado_text := "{%s}" % ", ".join(states_with_moves)

	if explicacion == "":
		explicacion = "La pieza puede moverse a {%s}" % ", ".join(states_with_moves)

	var row: Control = _row_scene.instantiate()
	rows_container.add_child(row)
	row.set_data(step, estado_actual, simbolo, transicion_text, nuevo_estado_text, explicacion)
	row.set_stripe_color(COLOR_EVEN if step % 2 == 0 else COLOR_ODD)

	_rows.append(row)
	return step


# --------------------------------------------------------------------
# 3) Comprobar estado válido (jaque mate encontrado -> fila en verde)
# --------------------------------------------------------------------
func mark_state_valid(step: int) -> void:
	if step < 0 or step >= _rows.size():
		return
	_rows[step].set_valid(true)


## Por si necesitas revertir la marca (el autómata retrocede / reinicia).
func unmark_state_valid(step: int) -> void:
	if step < 0 or step >= _rows.size():
		return
	_rows[step].set_valid(false)
