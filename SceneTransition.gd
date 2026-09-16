extends CanvasLayer

@onready var color_rect: ColorRect = $ColorRect
@onready var anim_player: AnimationPlayer = $AnimationPlayer

var _next_scene_path: String = ""

func _ready() -> void:
	layer = 100
	color_rect.visible = false

func transition_to_scene(path: String) -> void:
	_next_scene_path = path
	color_rect.visible = true
	anim_player.play("wipe_in")
	await anim_player.animation_finished
	
	get_tree().change_scene_to_file(_next_scene_path)
	
func play_wipe_out() -> void:
	anim_player.play("wip_out")
	await anim_player.animation_finished
	color_rect.visible = false
