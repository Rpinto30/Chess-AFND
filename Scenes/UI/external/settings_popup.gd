extends PopupPanel
## Copia del popup "Estilo de piezas": un botón que alterna entre
## Piezas Mayas / Piezas Clásicas, con Cancelar (descarta el cambio)
## y Guardar (confirma y avisa a quien esté escuchando).

signal piece_style_saved(style: String)

const STYLE_MAYAS := "mayas"
const STYLE_CLASSIC := "clasicas"

@onready var style_toggle_button: Button = %StyleToggleButton
@onready var cancel_button: Button = %CancelButton
@onready var save_button: Button = %SaveButton

var _saved_style: String = STYLE_MAYAS
var _pending_style: String = STYLE_MAYAS


func _ready() -> void:
	style_toggle_button.pressed.connect(_on_style_toggle_pressed)
	cancel_button.pressed.connect(_on_cancel_pressed)
	save_button.pressed.connect(_on_save_pressed)
	about_to_popup.connect(_on_about_to_popup)
	_update_toggle_label()


## Llamar desde afuera para que el popup sepa cuál es el estilo actual
## del juego (por ejemplo al cargar una preferencia guardada).
func set_current_style(style: String) -> void:
	_saved_style = style
	_pending_style = style
	_update_toggle_label()


func _on_about_to_popup() -> void:
	# Si se abre de nuevo sin haber guardado antes, no debe arrastrar
	# un cambio a medias.
	_pending_style = _saved_style
	_update_toggle_label()


func _on_style_toggle_pressed() -> void:
	_pending_style = STYLE_CLASSIC if _pending_style == STYLE_MAYAS else STYLE_MAYAS
	_update_toggle_label()


func _update_toggle_label() -> void:
	if _pending_style == STYLE_MAYAS:
		style_toggle_button.text = "  Piezas Mayas"
	else:
		style_toggle_button.text = "  Piezas Clásicas"


func _on_cancel_pressed() -> void:
	_pending_style = _saved_style
	hide()


func _on_save_pressed() -> void:
	_saved_style = _pending_style
	piece_style_saved.emit(_saved_style)
	hide()
