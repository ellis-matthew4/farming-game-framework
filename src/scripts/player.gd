extends CharacterBody2D

enum DIRS { DOWN, UP, LEFT, RIGHT }
var facing = DIRS.DOWN

func _ready():
	Globals.player = self
	Globals.camera = get_node("Camera2D")

func _physics_process(delta):
	if not Globals.movement_blocked:
		var xdirection = Input.get_axis("move_left", "move_right")
		if xdirection:
			velocity.x = xdirection * Globals.WALK_SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, Globals.WALK_SPEED)
		var ydirection = Input.get_axis("move_up", "move_down")
		if ydirection:
			velocity.y = ydirection * Globals.WALK_SPEED
		else:
			velocity.y = move_toward(velocity.y, 0, Globals.WALK_SPEED)
		
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
	
		_handle_walk_animation()
		move_and_slide()

func _handle_walk_animation():
	if Input.is_action_just_pressed("move_right"):
		$AnimatedSprite2D.play("right")
		facing = DIRS.RIGHT
	elif Input.is_action_just_pressed("move_left"):
		$AnimatedSprite2D.play("left")
		facing = DIRS.LEFT
	elif Input.is_action_just_pressed("move_down"):
		$AnimatedSprite2D.play("down")
		facing = DIRS.DOWN
	elif Input.is_action_just_pressed("move_up"):
		$AnimatedSprite2D.play("up")
		facing = DIRS.UP

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
