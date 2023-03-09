extends CharacterBody2D

func _physics_process(delta):
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
