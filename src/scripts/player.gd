extends CharacterBody2D

enum DIRS { DOWN, UP, LEFT, RIGHT, NONE }
var facing = DIRS.DOWN

var snap = Globals.map_grid_size
var snap_point
var moving = false
var last_movement_accepted = DIRS.NONE

signal turn(dir)
signal walk
signal reached

func _ready():
	Globals.player = self
	Globals.camera = get_node("Camera2D")
	self.turn.connect(_turn)
	self.walk.connect(_walk)
	self.reached.connect(_reached)

func _physics_process(delta):
	if not Globals.movement_blocked:
		if Input.is_action_just_pressed("player_interact"):
			velocity = Vector2(0,0)
			_interact()
		elif Input.is_action_just_pressed("player_cancel"):
			Globals.increment_day()
		elif Input.is_action_just_pressed("ux_menu"):
			Globals.menuLayer.ig_menu()
		elif Input.is_action_just_pressed("ux_pause"):
			Globals.menuLayer.pause_menu()
		elif Input.is_action_just_pressed("ux_debug"):
			Globals.menuLayer.debug_menu()
	
		if moving:
			if _snapped():
				global_position = snap_point
				emit_signal("reached")
				var input = _parse_movement()
				if input == last_movement_accepted:
					if Input.is_action_pressed("ux_modify"):
						snap_point = _snap(input)
					else:
						snap_point = _snap()
					emit_signal("walk")
				else:
					velocity = Vector2(0,0)
			else:
				velocity = _get_snap_vector() * Globals.WALK_SPEED
		else:
			var input = _parse_movement()
			if input != DIRS.NONE:
				_handle_walk(input)
				last_movement_accepted = input
			else:
				velocity = Vector2(0,0)
				
		# The constant here should be as small as possible to prevent jitter.
		var test_vector = velocity.normalized() * 1
		if test_move(transform, test_vector):
			_force_realign()
		else:
			move_and_slide()

func _parse_movement():
	if Input.is_action_pressed("move_right"):
		return DIRS.RIGHT
	elif Input.is_action_pressed("move_left"):
		return DIRS.LEFT
	elif Input.is_action_pressed("move_down"):
		return DIRS.DOWN
	elif Input.is_action_pressed("move_up"):
		return DIRS.UP
	else:
		return DIRS.NONE

func _handle_walk(input):
	if Input.is_action_pressed("ux_modify"):
		snap_point = _snap(input)
		moving = true
	else:
		emit_signal("turn", input)
		await get_tree().create_timer(0.05).timeout
		snap_point = _snap()
		if _parse_movement() == input:
			emit_signal("walk")
		
func get_direction():
	match(facing):
		DIRS.UP:
			return Vector2.UP
		DIRS.DOWN:
			return Vector2.DOWN
		DIRS.LEFT:
			return Vector2.LEFT
		DIRS.RIGHT:
			return Vector2.RIGHT

func get_real_position():
	return $InteractPivot.global_position
	
func _interact():
	var li = get_node("InteractPivot/InteractionArea").get_overlapping_bodies()
	for n in li:
		if n.is_in_group("Bed"):
			Globals.sleep()
			return
		if n.is_in_group("Door"):
			n.enter(self)
			return
	var currently_held_item = Globals.get_held_item()
	if currently_held_item is Tool:
		var tool = currently_held_item.item_name.to_snake_case()
		var animation = currently_held_item.animation_key + DIRS.keys()[facing].to_lower()
		print("Tool: " + tool + "/" + animation)
		# Play an animation and perform an action
	
func _cancel():
	pass
	
func _snapped():
	return global_position.distance_to(snap_point) < 4
	
func _get_snap_vector():
	return global_position.direction_to(snap_point)
	
func _snap(dir = null):
	var x = int(global_position.x)
	var y = int(global_position.y)
	var step_x = snappedi(x, snap)
	var step_y = snappedi(y, snap)
	if dir == null:
		dir = facing
	print(str(x,' ', y,' ', step_x,' ', step_y,' ',snap, ' ', dir))
	match(dir):
		DIRS.UP:
			step_y = step_y if step_y < y else step_y - snap
		DIRS.DOWN:
			step_y = step_y if step_y > y else step_y + snap
		DIRS.LEFT:
			step_x = step_x if step_x < x else step_x - snap
		DIRS.RIGHT:
			step_x = step_x if step_x > x else step_x + snap
	print(str(Vector2(step_x, step_y)))
	return Vector2(step_x, step_y)
	
func _force_realign():
	moving = false
	var x = int(global_position.x)
	var y = int(global_position.y)
	var step_x = snappedi(x, snap)
	var step_y = snappedi(y, snap)
	return Vector2(step_x, step_y)
	
func _turn(dir):
	var animation_keys = {
		DIRS.LEFT: 'left',
		DIRS.DOWN: 'down',
		DIRS.UP: 'up',
		DIRS.RIGHT: 'right'
	}
	$AnimatedSprite2D.play(animation_keys[dir])
	facing = dir
	_align_interact_pivot(facing)
	
func _walk():
	moving = true
	
func _reached():
	moving = false

func _align_interact_pivot(dir):
	var n = get_node("InteractPivot/InteractionArea")
	match(dir):
		DIRS.DOWN:
			n.position = Vector2(0, 16)
		DIRS.UP:
			n.position = Vector2(0, -16)
		DIRS.LEFT:
			n.position = Vector2(-16, 0)
		DIRS.RIGHT:
			n.position = Vector2(16, 0)
