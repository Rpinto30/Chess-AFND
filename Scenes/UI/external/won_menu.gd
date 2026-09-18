extends PopupPanel


signal exit_to_main_menu_requested
@export var exit_button: Button 

func _ready() -> void:
	exit_button.pressed.connect(_on_exit_pressed)

func _on_exit_pressed() -> void:
	exit_to_main_menu_requested.emit()
	self.hide()
	utils.transition_scene('Scenes/UI/main_menu.tscn')
