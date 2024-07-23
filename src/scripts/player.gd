extends Actor

var last_movement_accepted = DIRS.NONE

@onready var dummy = Globals.find_npc('player')
var follow_dummy = false

func _ready():
  speed_mod = 32
  Globals.player = self
  Globals.camera = get_node("Camera2D")
  if Globals.player_position != null:
    global_position = Globals.player_position
  connect("state_change", _on_state_change)

func _physics_process(delta):
  if follow_dummy:
    global_position = dummy.global_position
    return
  if not Globals.movement_blocked:
    super(delta)
    var currently_held_item_id = Globals.get_held_item()[0] if Globals.get_held_item() != null else null
    var currently_held_item = ItemDatabase.get_item(currently_held_item_id)
    if Input.is_action_just_pressed("player_interact"):
      velocity = Vector2(0,0)
      var held = false
      if currently_held_item is Tool:
        await get_tree().create_timer(0.1).timeout
        if Input.is_action_pressed("player_interact"):
          await get_tree().create_timer(0.1).timeout
          if Input.is_action_pressed("player_interact"):
            held = true
      _interact(held)
    elif Input.is_action_just_pressed("player_cancel"):
      Globals.player_position = global_position
      Globals.sleep()
    elif Input.is_action_just_pressed("ux_menu"):
      Globals.menuLayer.ig_menu()
    elif Input.is_action_just_pressed("ux_pause"):
      Globals.menuLayer.pause_menu()
    elif Input.is_action_just_pressed("ux_debug"):
      Globals.menuLayer.debug_menu()
    
    if state == states.IDLE:
      var input = _parse_movement()
      if input != Vector2(0,0) and travel_stack.size() == 0:
        input *= Globals.MAP_GRID_SIZE
        input += global_position
        travel_stack.append(Vector3(
          input.x,
          input.y,
          0 # walk
        ))
    elif state == states.MOVING:
      if _distance_to_target() <= 5:
        var input = _parse_movement()
        if input != Vector2(0,0) and travel_stack.size() == 0:
          input *= Globals.MAP_GRID_SIZE
          input += target
          travel_stack.append(Vector3(
            input.x,
            input.y,
            0 # walk
          ))
        
func _on_state_change(new_state):
  match(new_state):
    states.IDLE:
      $AnimatedSprite2D.stop()
    states.MOVING:
      pass
    states.NEXT:
      pass
    states.FINISHED:
      pass

func _parse_movement():
  if Input.is_action_pressed("move_right"):
    return Vector2.RIGHT
  elif Input.is_action_pressed("move_left"):
    return Vector2.LEFT
  elif Input.is_action_pressed("move_down"):
    return Vector2.DOWN
  elif Input.is_action_pressed("move_up"):
    return Vector2.UP
  else:
    return Vector2(0,0)
    
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
  var currently_held_item_id = Globals.get_held_item()[0] if Globals.get_held_item() != null else null
  var currently_held_item = ItemDatabase.get_item(currently_held_item_id)
  for n in li:
    if n.is_in_group("Bed"):
      Globals.player_position = null
      Globals.sleep()
      return
    elif n.is_in_group("Door"):
      n.enter(self)
      return
    elif n.is_in_group("ShippingBox"):
      if not currently_held_item is Tool:
        Globals.ship(currently_held_item_id, 1)
      return
    elif n is GroundItem:
      n.interact()
      return
    elif n is Soil:
      var interacted = n.interact()
      if interacted:
        return
    elif n is NPC:
      var npc_name = n.npc_name
      print('interacting with ', npc_name)
      n.turn_to_player()
      if not currently_held_item is Tool:
        var like_level = n.gift(currently_held_item)
        Globals.npc_talk_label(str(npc_name, "_gift_", like_level))
      else:
        Globals.affection_manager.talk_affection(n)
        Globals.npc_talk(npc_name)
      return
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
    Globals.remove_from_inventory(currently_held_item_id, 1)
    Globals.repopulate_quick_inventory()
  elif currently_held_item is Seeds or currently_held_item is Sapling:
    print("seeds")
    for n in li:
      if n is Soil and n.tilled:
        print("sowing")
        n.sow(currently_held_item)
        Globals.remove_from_inventory(currently_held_item_id, 1)
  elif currently_held_item is Consumable:
    if currently_held_item.item_name == "Fertilizer":
      for n in li:
        if n is Soil and n.tilled:
          n.fertilize()
          Globals.remove_from_inventory(currently_held_item_id, 1)
  else:
    if currently_held_item != null:
      print(currently_held_item.item_name)
  
func _cancel():
  pass
  
func turn_anim(anim):
  if Input.is_action_pressed("ux_modify"):
    $AnimatedSprite2D.play()
    return
  else:
    super(anim)
    _align_interact_pivot()

func _align_interact_pivot():
  var n = get_node("InteractPivot")
  match(facing):
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
  var snap = Globals.MAP_GRID_SIZE
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
