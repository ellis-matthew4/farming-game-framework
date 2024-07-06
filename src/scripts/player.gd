extends CharacterBody2D

enum DIRS { DOWN, UP, LEFT, RIGHT, NONE }
var facing = DIRS.DOWN

var snap = Globals.MAP_GRID_SIZE
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
  emit_signal("turn", facing)

func _physics_process(delta):
  if not Globals.movement_blocked:
    if Input.is_action_just_pressed("player_interact"):
      velocity = Vector2(0,0)
      var held = false
      if Globals.get_held_item() is Tool:
        await get_tree().create_timer(0.1).timeout
        if Input.is_action_pressed("player_interact"):
          await get_tree().create_timer(0.1).timeout
          if Input.is_action_pressed("player_interact"):
            held = true
      _interact(held)
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
  
func _interact(held):
  if held:
    _set_tool_interact_area_size(held)
    await get_tree().create_timer(0.05).timeout
  var li = get_node("InteractPivot/InteractionArea").get_overlapping_bodies()
  for n in li:
    if n.is_in_group("Bed"):
      Globals.sleep()
      return
    elif n.is_in_group("Door"):
      n.enter(self)
      return
    elif n.is_in_group("ShippingBox"):
      var held_item = Globals.get_held_item()
      if not held_item is Tool:
        Globals.ship(held_item)
      return
    elif n is GroundItem:
      n.interact()
      return
  var currently_held_item = Globals.get_held_item()
  if currently_held_item is Tool:
    var tool = currently_held_item.item_name.to_snake_case()
    var animation = currently_held_item.animation_key + DIRS.keys()[facing].to_lower()
    print("Tool: " + tool + "/" + animation)
    # Play an animation and perform an action
    for n in li:
      if n is Soil:
        if "hoe" in tool:
          n.hoe()
        elif "sickle" in tool:
          n.sickle()
        elif "watering_can" in tool:
          n.water()
        elif "hammer" in tool:
          n.hammer()
        elif "axe" in tool:
          n.axe()
        print("interacting with soil")
    await get_tree().create_timer(0.25).timeout
    _set_tool_interact_area_size(false)
  elif currently_held_item is Food:
    currently_held_item.consume()
    Globals.repopulate_quick_inventory()
  elif currently_held_item is Seeds:
    print("seeds")
    for n in li:
      if n is Soil and n.tilled:
        print("sowing")
        n.sow(currently_held_item)
        currently_held_item.consume()
  elif currently_held_item is Consumable:
    if currently_held_item.item_name == "Fertilizer":
      for n in li:
        if n is Soil and n.tilled:
          n.fertilize()
          currently_held_item.consume()
  else:
    if currently_held_item != null:
      print(currently_held_item.item_name)
  
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
  match(dir):
    DIRS.UP:
      step_y = step_y if step_y < y else step_y - snap
    DIRS.DOWN:
      step_y = step_y if step_y > y else step_y + snap
    DIRS.LEFT:
      step_x = step_x if step_x < x else step_x - snap
    DIRS.RIGHT:
      step_x = step_x if step_x > x else step_x + snap
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
  var n = get_node("InteractPivot")
  match(dir):
    DIRS.DOWN:
      n.rotation_degrees = 180
    DIRS.UP:
      n.rotation_degrees = 0
    DIRS.LEFT:
      n.rotation_degrees = 270
    DIRS.RIGHT:
      n.rotation_degrees = 90

func _set_tool_interact_area_size(held = false):
  var t = Globals.get_held_item()
  var n = $InteractPivot/InteractionArea/CollisionShape2D
  if held and t is Tool and t.level > 1:
    match(t.level):
      2:
        n.shape.size = Vector2(snap-1, snap-1)
        n.position = Vector2(0, -snap * 1.5)
      3:
        n.shape.size = Vector2(snap-1,snap*2-1)
        n.position = Vector2(0, -snap * 2)
      4:
        n.shape.size = Vector2(snap*2-1,snap*2-1)
        n.position = Vector2(0, -snap * 2)
      5:
        n.shape.size = Vector2(snap*2-1,snap*3-1)
        n.position = Vector2(0, -snap * 2.5)
  else:
        n.shape.size = Vector2(snap / 2, snap / 2)
        n.position = Vector2(0, -snap)

func _on_pick_up_area_body_entered(body):
  body.interact()
