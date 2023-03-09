extends CharacterBody2D

var ingame_menu = preload("res://scenes/Menus/ingame_menu.tscn")

func _ready():
	Globals.player = self

func _physics_process(delta):
	if not Globals.movement_blocked:
		var xdirection = Input.get_axis("move_left", "move_right")
		if xdirection:
			velocity.x = xdirection * Globals.WALK_SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, Globals.WALK_SPEED)
		var ydirection = Input.get_axis("move_up", "move_down")
		if ydirection:
			velocity.x = ydirection * Globals.WALK_SPEED
		else:
			velocity.x = move_toward(velocity.y, 0, Globals.WALK_SPEED)
		
		if Input.is_action_just_pressed("player_interact"):
			velocity = Vector2(0,0)
			_interact()
		elif Input.is_action_just_pressed("player_cancel"):
			_cancel()
		elif Input.is_action_just_pressed("ux_menu"):
			_menu()
		elif Input.is_action_just_pressed("ux_pause"):
			_pause()
	
		_handle_walk_animation()
		move_and_slide()

func _handle_walk_animation():
	if Input.is_action_just_pressed("move_right"):
		$AnimatedSprite2D.play("right")
	elif Input.is_action_just_pressed("move_left"):
		$AnimatedSprite2D.play("left")
	elif Input.is_action_just_pressed("move_down"):
		$AnimatedSprite2D.play("down")
	elif Input.is_action_just_pressed("move_up"):
		$AnimatedSprite2D.play("up")

func _interact():
	pass
	
func _cancel():
	pass
	
func _menu():
	Globals.movement_blocked = true
	$CanvasLayer/quick_inventory.hide()
	$CanvasLayer.add_child(ingame_menu.instantiate())
	
func menu_hide(menu):
	Globals.movement_blocked = false
	$CanvasLayer/quick_inventory.show()
	menu.queue_free()
	
func _pause():
	Globals.pause()
