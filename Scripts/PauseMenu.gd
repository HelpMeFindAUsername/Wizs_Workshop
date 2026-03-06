extends CanvasLayer

@onready var panel = $Pause
@onready var settings: Panel = $Settings

@onready var res: Button = $Pause/Res
@onready var settings_b: Button = $Pause/SettingsB
@onready var btt: Button = $Pause/BTT

@onready var back: Button = $Settings/back

func _ready():
	panel.visible = 0
	settings.visible = 0
	
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
	
	
func _unhandled_input(event):
	if event.is_action_pressed("pause"):
		togglePause()

func togglePause():
	get_tree().paused = !get_tree().paused
	panel.visible = !panel.visible


func resume():
	togglePause()
	
func toggleSett():
	settings.visible = !settings.visible
	panel.visible = !panel.visible
