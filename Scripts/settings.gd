extends CanvasLayer

@onready var back: Button = $Panel/back

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	back.pressed.connect(goBack)
	
func goBack():
	if global.settingsStatus:
		get_tree().change_scene_to_file("res://Scenes/game.tscn")
	else:
		get_tree().change_scene_to_file("res://Scenes/UI/TitleSc.tscn")
