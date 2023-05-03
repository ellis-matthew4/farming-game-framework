extends CharacterBody2D

enum DIRS { DOWN, UP, LEFT, RIGHT }
var facing = DIRS.DOWN
var vertical = DIRS.DOWN
var horizontal = DIRS.RIGHT
var stopping = false

var snap = Globals.map_grid_size
var snap_point

signal turn(dir)
signal walk
signal stop

func _ready():
	Globals.player = self
	Globals.camera = get_node("Camera2D")
	self.turn.connect(_turn)
	self.walk.connect(_walk)
	self.stop.connect(_stop)

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
	
		_handle_walk()
		move_and_slide()

func _handle_walk():
	if not stopping:
		if Input.is_action_pressed("move_right"):
			emit_signal("turn", DIRS.RIGHT)
			await get_tree().create_timer(0.05).timeout
			if Input.is_action_pressed("move_right"):
				emit_signal("walk")
		elif Input.is_action_pressed("move_left"):
			emit_signal("turn", DIRS.LEFT)
			await get_tree().create_timer(0.05).timeout
			if Input.is_action_pressed("move_left"):
				emit_signal("walk")
		elif Input.is_action_pressed("move_down"):
			emit_signal("turn", DIRS.DOWN)
			await get_tree().create_timer(0.05).timeout
			if Input.is_action_pressed("move_down"):
				emit_signal("walk")
		elif Input.is_action_pressed("move_up"):
			emit_signal("turn", DIRS.UP)
			await get_tree().create_timer(0.05).timeout
			if Input.is_action_pressed("move_up"):
				emit_signal("walk")
		elif velocity != Vector2(0,0):
			emit_signal("stop")
	else:
		if _snapped():
			if global_position.direction_to(snap_point) == get_direction():
				velocity = Vector2(0,0)
				global_position = snap_point
				stopping = false
			else:
				emit_signal("stop")
		else:
			velocity = _get_snap_vector() * Globals.WALK_SPEED
	_align_interact_pivot(facing)
		
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
	
func _snap():
	var x = int(global_position.x)
	var y = int(global_position.y)
	var mod = 0
	match(facing):
		DIRS.UP:
			mod = posmod(y, snap)
			y -= mod
		DIRS.DOWN:
			mod = snap - posmod(y, snap)
			y += mod
		DIRS.LEFT:
			mod = posmod(x, snap)
			x -= mod
		DIRS.RIGHT:
			mod = snap - posmod(x, snap)
			x += mod
	var result = Vector2(x,y)
	return result
	
func _turn(dir):
	if velocity != Vector2(0,0) and facing != dir:
		emit_signal("stop")
		return
	match(dir):
		DIRS.DOWN:
			$AnimatedSprite2D.play("down")
			facing = DIRS.DOWN
			horizontal = DIRS.DOWN
		DIRS.LEFT:
			$AnimatedSprite2D.play("left")
			facing = DIRS.LEFT
			horizontal = DIRS.LEFT
		DIRS.UP:
			$AnimatedSprite2D.play("up")
			facing = DIRS.UP
			horizontal = DIRS.UP
		DIRS.RIGHT:
			$AnimatedSprite2D.play("right")
			facing = DIRS.RIGHT
			horizontal = DIRS.RIGHT
	
func _walk():
	velocity = get_direction() * Globals.WALK_SPEED
	
func _stop():
	stopping = true
	snap_point = _snap()

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
