class_name PopupControl
extends Popup

@export var whites: HBoxContainer
@export var blacks: HBoxContainer

@export var buttons_whites: Array[Button]
@export var buttons_black: Array[Button]

signal coronate_select_type(select_type: int, color: int)

func _ready() -> void:
	for i in range(4):
		var piece_type: int = i + 1
		
		if buttons_whites.size() > i and buttons_whites[i] != null:
			buttons_whites[i].pressed.connect(set_piece.bind(piece_type, 0))
			
		if buttons_black.size() > i and buttons_black[i] != null:
			buttons_black[i].pressed.connect(set_piece.bind(piece_type, 1))
	hide()
	popup_hide.connect(_on_popup_hide)
	
#"Knight" 1 
#"Bishop" 2
#"Rook" 3
#"Queen" 4

func show_mouse(screen_pos: Vector2i) -> void:
	popup(Rect2i(screen_pos, size))

func set_piece(piece: int, color: int) -> void:
	coronate_select_type.emit(piece, color)
	hide() 
	
func _on_popup_hide() -> void:
	for con in coronate_select_type.get_connections():
		coronate_select_type.disconnect(con.callable)
