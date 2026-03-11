extends Node2D

@onready var lines = $Lines

const  MIN_DISTANCE_BETWEEN_POINTS = 5.0 #Minimum distance to create a new point for the line to draw

var lmb_pressed : bool

var current_line : Line2D
var lines_drawn := []

@export var control_points_num := 32
var total_control_points := []

@export var record := false #Can you record new shapes?
@export var save_keycode := KEY_SHIFT
@export var shapes_folder_path := "res://Gestures/"
@export var file_name := "New_Shape"
var loaded_shapes := {}
@export var sort_key = "x"
@export var recognition_threshold := 0.085 #Higher = more forgiving

#DEBUG FUNCTION TO CHECK IF CONTROL POINTS GET REGISTERED
#--------------------------------------------------------------------------
@export var show_control_points := true

func _ready():
	load_shapes()

func _draw():
	if show_control_points:
		lines.z_index = -1
		for point in total_control_points:
			draw_circle(to_local(point), 4.0, Color.GREEN)

func set_points():
	queue_redraw()
#--------------------------------------------------------------------------

func _unhandled_input(event):
	if event is InputEventKey and event.pressed:
		
		#Save shapes
		if event.keycode == save_keycode:
			if total_control_points.size() > 0:
				var sorted_points = sort_points(total_control_points.duplicate(), sort_key)
				save_control_points_to_resource(sorted_points)
				print("Saved CP (control points, chill)")
			
			else:
				print("il bro non ha faige da salvare, L bozo + stay mad")

func _input(event):
	#Check for mouse lmb input (true or false)
	if (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT):
		lmb_pressed = event.pressed
		print (str(lmb_pressed))
		
		#If true start a new line else append line to the total amount of lines
		if lmb_pressed:
			start_new_line()
		else:
			if current_line and current_line.points.size() > 1:
				lines_drawn.append(current_line.points)
				print ("Total amount of lines drawn: " + (str(lines_drawn.size())))
				update_control_points()
				set_points()
				recognize_shape(total_control_points)
	
	elif event is InputEventMouseMotion and lmb_pressed and current_line:
		var new_point = get_local_mouse_position()
		if current_line.points.size() == 0 or current_line.points[-1].distance_to(new_point) >= MIN_DISTANCE_BETWEEN_POINTS:
			current_line.add_point(new_point)
		

func start_new_line():
	current_line = Line2D.new()
	
	current_line.default_color = Color.WHITE
	current_line.width = 14.0
	
	lines.add_child(current_line)
	
	print("NEW LINE ADDED")

func update_control_points():
	
	total_control_points.clear() #Clears the previously added control points to add new ones after the segmentation of new lines
	
	var total_lines = lines_drawn.size()
	if total_lines == 0:
		return
	
	var control_points_per_line = max(2, int(control_points_num / total_lines)) #Checks to distribute the control points along the lines
	for line in lines_drawn:
		var segmented = segmentation(line, control_points_per_line)
		total_control_points += segmented
	
	if total_control_points.size() > control_points_num:
		var points_to_keep = []
		points_to_keep.append(total_control_points[0])
		
		var num_middle_points = control_points_num - 2 #Does so to avoid considering the 2 ends of a line into the equation
		var middle_points = total_control_points.slice(1, total_control_points.size() - 2)
		
		#I don't know what the fuck is going on here, it was late and I was disgustingly tired fuck this
		if middle_points.size() > num_middle_points:
			var step = float((middle_points.size() - 1) / (num_middle_points - 1))
			for i in range(num_middle_points):
				var idx = int(round(i*step))
				idx = clamp(idx, 0, middle_points.size() -1)
				points_to_keep.append(middle_points[idx])
		else:
			points_to_keep += middle_points
		
		points_to_keep.append(total_control_points[-1])
		total_control_points = points_to_keep
	
	#Time to add new controlpoints if there's not enough my sister is fucking pissing me of she's playing her fuckass battery in my goddamn room fuck my life she could've just fucking set that up in the garage god fucking dammit i'm so full of this shit i'm going to kill myself some day or another i swear to fucking christ
	var extra_needed = control_points_num - total_control_points.size()
	if extra_needed > 0:
		var center_point = find_center(total_control_points)
		var radius = 10.0
		for i in range(extra_needed):
			var angle = (TAU / extra_needed) * i
			var offset = Vector2(cos(angle), sin(angle)) * radius
			total_control_points.append(center_point + offset)
	print("Total amount of control points: " + (str(total_control_points.size())))

func segmentation (points: Array, count: int) -> Array:
	#THIS FUNCTION IS USED TO DIVIDE THE LINES INTO SEGMENTS WHICH GET USED TO CREATE CONTROL POINTS I WANT TO KILL MYSELF
	if points.size() < 2 or count < 2:
		return points.duplicate()
	
	#it begins by setting up 2 variables, one to store the total length of the line, the second to store the lenghts of all the segments
	var total_length := 0.0
	var segment_lengths := []
	
	for i in range(points.size() - 1):
		var seg_len = points[i].distance_to(points[i+1])
		segment_lengths.append(seg_len)
		total_length += seg_len #adds to the total length of the drawing the lenght of a single segment
	
	var result := [points[0]]
	var distance_step := total_length / (count -1) #divides the total length by the amount of segments to cut into equal parts
	var distance_accum := 0.0
	var current_segment := 0
	
	for i in range(1, count - 1):
		var target_distance := i * distance_step
		
		while current_segment < segment_lengths.size() and distance_accum + segment_lengths[current_segment] < target_distance:
			distance_accum += segment_lengths[current_segment]
			current_segment +=1
		
		if current_segment >= segment_lengths.size():
			break
		
		#Actual segmentation
		var seg_start = points[current_segment]
		var seg_end = points[current_segment + 1]
		var seg_length = segment_lengths[current_segment]
		var remaining = target_distance - distance_accum
		var t = remaining / seg_length
		
		#Add new point to the line
		var new_point = seg_start.lerp(seg_end, t)
		result.append(new_point)
	
	result.append(points[-1])
	return result

func load_shapes():
	#Guess what this does
	var dir = DirAccess.open(shapes_folder_path)
	if dir:
		dir.list_dir_begin()
		
		#Load each shape
		var next_file = dir.get_next()
		while next_file != "":
			if next_file.ends_with(".tres"):
				var full_path = shapes_folder_path + "/" + next_file #Get the full path to the file
				var res = load(full_path) #then load as a resource
				if res and res is ControlPointsData:
					name = (next_file.get_basename()).to_upper()
					loaded_shapes[name] = {"points": res.points, "min_lines": res.min_lines_required} #The every data thingy
					
					print("Loaded shape: ", name, ", Min lines required: ", res.min_lines_required)
			
			next_file = dir.get_next()
			
	
	#Just in case
	else:
		print("Failed to open saved shapes, L bozo")

#MINMAX THIS BITCH!!!uhidshflveashblkirugfjaloieuwsrfp
func find_center(points: Array) -> Vector2:
	var min_x = INF
	var max_x = -INF
	var min_y = INF
	var max_y = -INF
	for point in points:
		min_x = min(min_x, point.x)
		max_x = max(max_x, point.x)
		min_y = min(min_y, point.y)
		max_y = max(max_y, point.y)
	
	return Vector2((min_x + max_x) * 0.5, (min_y + max_y) * 0.5)

func sort_points(points: Array, by: String = "x") -> Array:
	#Sort points either by x or y coords
	match by:
		"x":
			points.sort_custom(func(a, b): return a.x < b.x or (a.x == b.x and a.y < b.y))
		
		"y":
			points.sort_custom(func(a, b): return a.y < b.y or (a.y == b.y and a.x < b.x))
	
	return points

func save_control_points_to_resource(points : Array):
	if record:
		var resource = ControlPointsData.new()
		resource.set_points(points)
		
		#Make sure the resource folder exist
		if not DirAccess.dir_exists_absolute(shapes_folder_path):
			var make_result = DirAccess.make_dir_recursive_absolute(shapes_folder_path)
			if make_result != OK:
				print ("failed to create directory for saving gestures, what's left to do is killing yourself... I'm sorry")
				return
		
		var save_path = shapes_folder_path + "/" + file_name + ".tres"
		var unique_save_path = save_path
		var count =1
		
		#This makes sure that every time that a new shape is added it doesn't overwrite one with the same name
		while FileAccess.file_exists(unique_save_path):
			unique_save_path = shapes_folder_path + "/" + file_name + "_" + str(count) + ".tres"
			count += 1
		
		var result = ResourceSaver.save(resource, unique_save_path)
		if result == OK:
			print("Control points saved to:" + unique_save_path)
		else:
			print("Fam sum went wrong, damn son :sob:")

func preprocess_points(points: Array) -> Array:
	points = segmentation(points, control_points_num)
	points = sort_points(points, sort_key)
	return points

func path_distance(points1: Array, points2: Array) -> float:
	
	#Get total distance from point 1 to 2
	var total_dist_1to2 := 0.0
	for p1 in points1:
		var min_dist := INF
		for p2 in points2:
			var dist = p1.distance_to(p2)
			if dist < min_dist:
				min_dist = dist
			
		total_dist_1to2 += min_dist
	
	#Get total distance from point 2 to 1
	
	var total_dist_2to1 := 0.0
	for p2 in points2:
		var min_dist := INF
		for p1 in points1:
			var dist = p2.distance_to(p1)
			if dist < min_dist:
				min_dist = dist
			
		total_dist_2to1 += min_dist
	
	#Average distance between points
	var avg_dist = (total_dist_1to2 + total_dist_2to1) / (points1.size() + points2.size())
	
	#Scale invariance so that no matter the size it gets recognized
	var bounds = calculate_bounds(points1)
	var gesture_size = max(bounds.size.x, bounds.size.y, 1.0)
	
	return avg_dist / gesture_size

func calculate_bounds(points: Array) -> Rect2:
	var min_x = INF
	var max_x = -INF
	var min_y = INF
	var max_y = -INF
	for p in points:
		min_x = min(min_x, p.x)
		max_x = max(max_x, p.x)
		min_y = min(min_y, p.y)
		max_y = max(max_y, p.y)
	
	return Rect2(Vector2(min_x, min_y), Vector2(max_x - min_x, max_y - min_y))

func recognize_shape(input_points: Array):
	#if no shapes return nothing duh
	if loaded_shapes.is_empty():
		print("no shapes to compare")
		return ""
	
	var best_distance = INF
	
	var input = preprocess_points(input_points)
	
	#For each shape take data
	for name in loaded_shapes.keys():
		var saved_data = loaded_shapes[name]
		var required_lines = saved_data.get("min_lines", 1)
		
		#If there's not enough lines drawn
		if lines_drawn.size() < required_lines:
			print("Shape '%s' skipped: only %d lines drawn, requires %d" %[name, lines_drawn.size(), required_lines]) #The % is used to refer to array variables that follow the print
			continue
		
		#If the number of lines drawn is enough
		var saved = preprocess_points(saved_data.points)
		var dist = path_distance(input, saved)
		if dist < best_distance:
			best_distance = snapped(dist, 0.001)
			
			#Get rid of unnecessary suffix
			
			name = name.replace("_", "")
			name = name.replace("0", "")
			name = name.replace("1", "")
			name = name.replace("2", "")
			name = name.replace("3", "")
			name = name.replace("4", "")
			name = name.replace("5", "")
			name = name.replace("6", "")
			name = name.replace("7", "")
			name = name.replace("8", "")
			name = name.replace("9", "")
			
			Global.best_match = name
	
	print("Best match:", Global.best_match, ", Distance:", best_distance)
	
	#If the distance is greater than the threshold then it doesn't match
	if best_distance > recognition_threshold:
		Global.best_match = "No match"
		
		print("Drawing too weird, no match for you loser!")
