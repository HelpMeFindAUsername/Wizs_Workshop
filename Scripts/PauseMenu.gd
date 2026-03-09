extends CanvasLayer

@onready var panel = $Pause
@onready var settings: Panel = $Settings

@onready var res: Button = $Pause/Res
@onready var settings_b: Button = $Pause/SettingsB
@onready var btt: Button = $Pause/BTT

@onready var back: Button = $Settings/back

@onready var ee: Sprite2D = $ShonoRisharshato

var pauseCount = 0

func _ready():
	panel.visible = 0
	settings.visible = 0
	ee.visible = 0
	
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	
	#L'if della smisurata infelicità e solitudine
	var unhappyness = randi_range(0, 1)
	if unhappyness == 1:
		print("Provo estreme infelicità e solitudine")
	else:
		print("Boh ci sta")
	
	res.pressed.connect(resume)
	settings_b.pressed.connect(toggleSett)
	back.pressed.connect(toggleSett)
	btt.pressed.connect(backTitleScreen)
	
	
func backTitleScreen():
	togglePause()
	get_tree().change_scene_to_file("res://Scenes/UI/TitleSc.tscn")

func _unhandled_input(event):
	if event.is_action_pressed("pause") && ((!panel.visible && !settings.visible) || (panel.visible && !settings.visible)):
		togglePause()
	
	elif event.is_action_pressed("pause") && settings.visible:
		settings.visible = !settings.visible
		panel.visible = !panel.visible

func togglePause():
	ee.visible = 0
	get_tree().paused = !get_tree().paused
	panel.visible = !panel.visible
	if panel.visible:
		pauseCount = pauseCount + 1
		if pauseCount == 6:
			ee.visible = 1
			pauseCount = 0
	
func resume():
	togglePause()
	
func toggleSett():
	settings.visible = !settings.visible
	panel.visible = !panel.visible
