extends CharacterBody2D

enum DIRS { DOWN, UP, LEFT, RIGHT }
var facing = DIRS.DOWN
var vertical = DIRS.DOWN
var horizontal = DIRS.RIGHT
var moving = false

var snap = Globals.map_grid_size

func _ready():
	Globals.player = self
	Globals.camera = get_node("Camera2D")

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
	if Input.is_action_pressed("move_right"):
		$AnimatedSprite2D.play("right")
		moving = true
		facing = DIRS.RIGHT
		horizontal = DIRS.RIGHT
		velocity = Vector2.RIGHT * Globals.WALK_SPEED
	elif Input.is_action_pressed("move_left"):
		$AnimatedSprite2D.play("left")
		moving = true
		facing = DIRS.LEFT
		horizontal = DIRS.LEFT
		velocity = Vector2.LEFT * Globals.WALK_SPEED
	elif Input.is_action_pressed("move_down"):
		$AnimatedSprite2D.play("down")
		moving = true
		facing = DIRS.DOWN
		vertical = DIRS.DOWN
		velocity = Vector2.DOWN * Globals.WALK_SPEED
	elif Input.is_action_pressed("move_up"):
		$AnimatedSprite2D.play("up")
		moving = true
		facing = DIRS.UP
		vertical = DIRS.UP
		velocity = Vector2.UP * Globals.WALK_SPEED
	else:
		if _snapped():
			velocity = Vector2(0,0)
			global_position = _snap()
		else:
			velocity = _get_snap_vector() * Globals.WALK_SPEED
		
func _interact():
	var slot = Globals.menuLayer.get_node("quick_inventory").focused_index - 1
	var currently_held_item = Globals.inventory[slot]
	if currently_held_item is Tool:
		var tool = currently_held_item.item_name.to_snake_case()
		var animation = currently_held_item.animation_key + DIRS.keys()[facing].to_lower()
		print("Tool: " + tool + "/" + animation)
		# Play an animation and perform an action
	
func _cancel():
	pass
	
func _snapped():
	return global_position.distance_to(_snap()) < 4
	
func _get_snap_vector():
	return global_position.direction_to(_snap())
	
func _snap():
	var x = int(global_position.x)
	var y = int(global_position.y)
	var x_modifier = 1 if horizontal == DIRS.RIGHT else -1
	var y_modifier = 1 if vertical == DIRS.DOWN else -1
	while x % snap != 0 or y % snap != 0:
		x += x_modifier if x % snap != 0 else 0
		y += y_modifier if y % snap != 0 else 0
	print(Vector2(x,y))
	return Vector2(x,y)
