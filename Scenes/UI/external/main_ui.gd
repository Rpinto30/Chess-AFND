class_name PRINCIPALMENU
extends Control
## UI principal del juego. Contiene la barra superior (menú + título),
## la fila de jugadores (nombre, tiempo, puntaje) y por ahora un
## placeholder verde donde luego irá el tablero real.

signal exit_to_main_menu_requested
signal piece_style_changed(style: String)

@onready var menu_button: Button = %MenuButton
@export var pause_menu: PopupPanel #= %PauseMenu
@export var settings_popup: PopupPanel #= %SettingsPopup
@export var afnd_table: PopupPanel 

@export var show_afnd_button: Button 
@onready var player1_name_label: Label = %Player1NameLabel
@onready var player1_time_label: Label = %Player1TimeLabel
@onready var player1_score_label: Label = %Player1ScoreLabel

@onready var player2_name_label: Label = %Player2NameLabel
@onready var player2_time_label: Label = %Player2TimeLabel
@onready var player2_score_label: Label = %Player2ScoreLabel


func _ready() -> void:
	menu_button.pressed.connect(_on_menu_button_pressed)
	pause_menu.open_settings_requested.connect(_on_open_settings_requested)
	pause_menu.exit_to_main_menu_requested.connect(_on_exit_to_main_menu_requested)
	settings_popup.piece_style_saved.connect(_on_piece_style_saved)
	show_afnd_button.pressed.connect(_on_show_afnd_pressed)  

	
func _on_menu_button_pressed() -> void:
	pause_menu.popup_centered()


func _on_open_settings_requested() -> void:
	settings_popup.popup_centered()


func _on_exit_to_main_menu_requested() -> void:
	pause_menu.hide()
	exit_to_main_menu_requested.emit()
	# Si tu pantalla principal ya existe, puedes cambiar directamente:
	# get_tree().change_scene_to_file("res://main_menu.tscn")


func _on_piece_style_saved(style: String) -> void:
	piece_style_changed.emit(style)


func _on_show_afnd_pressed() -> void:
	afnd_table.show()


# --------------------------------------------------------------------
# API pública para que la escena del juego (o el tablero) actualice
# lo que se muestra en esta UI.
# --------------------------------------------------------------------

func set_player_name(player_index: int, player_name: String) -> void:
	if player_index == 1:
		player1_name_label.text = player_name
	else:
		player2_name_label.text = player_name


## time_text ya formateado, ej: "10:00:00"
func set_player_time(player_index: int, time_text: String) -> void:
	if player_index == 1:
		player1_time_label.text = time_text
	else:
		player2_time_label.text = time_text


func set_player_score(player_index: int, score: int) -> void:
	if player_index == 1:
		player1_score_label.text = str(score)
	else:
		player2_score_label.text = str(score)


## Útil para inicializar el popup con la preferencia guardada del jugador.
func set_current_piece_style(style: String) -> void:
	settings_popup.set_current_style(style)
	

#============================================
func set_afnd_current_string(cadena: String) -> void:
	afnd_table.set_current_string(cadena)


func afnd_clear_table() -> void:
	afnd_table.clear_table()


func afnd_add_instruction(estado_actual: String, simbolo: String, transiciones: Array, explicacion: String = "") -> int:
	return afnd_table.add_instruction(estado_actual, simbolo, transiciones, explicacion)


func afnd_mark_state_valid(step: int) -> void:
	afnd_table.mark_state_valid(step)
