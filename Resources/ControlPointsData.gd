extends Resource
class_name ControlPointsData

@export var points: Array = []
@export var min_lines_required = 1

#Ensure type safety at runtime
func set_points(new_points: Array):
	points = []
	for p in new_points:
		if typeof(p) == TYPE_VECTOR2:
			points.append(p)
