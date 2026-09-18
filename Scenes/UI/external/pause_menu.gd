extends PopupPanel
## Menú de pausa: se abre desde el botón de menú (≡) de la UI principal.
## Emite señales en vez de tomar decisiones por sí mismo, así la escena
## principal (o el manejador de escenas del juego) decide qué hacer.

signal open_settings_requested
signal exit_to_main_menu_requested

@onready var resume_button: Button = %ResumeButton
@onready var settings_button: Button = %SettingsButton
@onready var exit_button: Button = %ExitButton


func _ready() -> void:
	resume_button.pressed.connect(_on_resume_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	exit_button.pressed.connect(_on_exit_pressed)


func _on_resume_pressed() -> void:
	hide()


func _on_settings_pressed() -> void:
	hide()
	open_settings_requested.emit()


func _on_exit_pressed() -> void:
	exit_to_main_menu_requested.emit()
	utils.transition_scene('Scenes/UI/main_menu.tscn')
