extends HSlider

@export var busName: String
var busIndex: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	busIndex = AudioServer.get_bus_index(busName)
	value_changed.connect(cambioVal)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

#Volume
func cambioVal(vol: float):
	AudioServer.set_bus_volume_linear(busIndex, vol)
	print(vol)
