extends Actor

class_name NPC

@export var npc_name: String
@export var can_marry: bool
@export var spouse: bool
@export var birthday: String # expects SEASON/DAY

var birth_month
var birth_day

var in_dialog = false

var wandering = false
var rto_tick = 360

var schedule = {}

var buffered_anim
var buffered_flip
var event_mode = false:
  set(mode):
    if mode == true:
      travel_stack = []
      velocity = Vector2(0,0)
      state = states.IDLE
    else:
      pass

func _ready():
  super()
  speed_mod = 16
  var path = str("res://assets/schedules/", npc_name, ".json")
  var file = FileAccess.open(path, FileAccess.READ)
  if file != null:
    var data = file.get_as_text()
    file.close()
    var json = JSON.new()
    var error = json.parse(data)
    if error != OK:
      print("FAILED TO READ FILE " + path)
      return
    data = json.data
    # for now only care about day of week
    # TODO: expand to care about season
    var dow = str(Globals.calendar.dow)
    schedule = _parse(data[dow])
  Globals.clock.tick.connect(_on_clock_tick)
  birth_month = int(birthday.split('/')[0])
  birth_day = int(birthday.split('/')[1])
  connect("state_change", _on_state_change)
  
func _parse(data):
  var result = {}
  for key in data.keys():
    var positions = []
    for pos in data[key]:
      positions.append(Vector3(pos['x'], pos['y'], pos['z']))
    result[key] = positions
  return result

func teleport_based_on_schedule():
  travel_stack = []
  for t in schedule.keys():
    if int(t) > Globals.clock.time:
      var pos = schedule[t].back()
      pos.z = 1
      travel_stack.append(pos)
      return
  travel_stack.append(Vector3(origin.x, origin.y, 1))
  
func return_to_origin_tick():
  for t in schedule.keys():
    if int(t) > Globals.clock.time:
      return int(t) - 10
  
func _physics_process(delta):
  if in_dialog:
    velocity = Vector2(0,0)
    $AnimatedSprite2D.stop()
    move_and_slide()
    return
  set_collision_layer_value(2, state == states.IDLE)
  var player = Globals.player()
  if player != null:
    z_index = (player.z_index + 1) if global_position.y > player.global_position.y else (player.z_index - 1)
    z_index = 100
  super(delta)
  move_and_slide()
    
func _on_state_change(new_state):
  match(new_state):
    states.IDLE:
      $AnimatedSprite2D.stop()
    states.MOVING:
      pass
    states.NEXT:
      pass
    states.FINISHED:
      if not event_mode:
        wandering = true
      
func _already_there(pos):
  return global_position == Vector2(pos.x, pos.y)
    
func _on_clock_tick():
  var time = str(Globals.clock.time)
  if schedule.has(time):
    if not _already_there(schedule[time].back()):
      travel_stack.append_array(schedule[time])
      wandering = false
  if rto_tick == int(time):
    if global_position == origin:
      return
    var v
    if origin.x > global_position.x:
      v = (global_position + (Vector2.RIGHT * Globals.MAP_GRID_SIZE))
    elif origin.x < global_position.x:
      v = (global_position + (Vector2.LEFT * Globals.MAP_GRID_SIZE))
    elif origin.y > global_position.y:
      v = (global_position + (Vector2.DOWN * Globals.MAP_GRID_SIZE))
    elif origin.y < global_position.y:
      v = (global_position + (Vector2.UP * Globals.MAP_GRID_SIZE))
    travel_stack.append(Vector3(v.x, v.y, 0))
    if v != origin:
      travel_stack.append(Vector3(origin.x, origin.y, 0))
  else:
    if rto_tick != null:
      if int(time) > rto_tick:
        return
    if int(time) % 5 == 0:
      wander()
      
func wander():
  var dir = [Vector2.RIGHT, Vector2.LEFT, Vector2.UP, Vector2.DOWN][randi() % 4]
  var dest = global_position + (dir * Globals.MAP_GRID_SIZE)
  if is_in_bounds(dest):
    var pos = Vector3(dest.x, dest.y, 0)
    travel_stack.append(pos)

func target_vec():
  return (target - global_position).normalized()
  
func is_in_bounds(vec):
  if bounds == null:
    return false
  if vec.x < bounds[0].x:
    return false
  if vec.y < bounds[0].y:
    return false
  if vec.x > bounds[1].x:
    return false
  if vec.y > bounds[1].y:
    return false
  return true
  
func turn_to_player():
  in_dialog = true
  var p = Globals.player()
  var vec = (p.global_position - global_position).normalized()
  buffered_anim = $AnimatedSprite2D.animation
  buffered_flip = $AnimatedSprite2D.flip_h
  handle_turn(vec)

func gift(item: Item):
  item.quantity -= 1
  return Globals.affection_manager.gift_affection(self, ItemDatabase.get_id(item))

func is_birthday():
  return Globals.calendar.season == birth_month and Globals.calendar.day == birth_day

func end_dialog():
  in_dialog = false
  if state != states.IDLE:
    if buffered_anim:
      $AnimatedSprite2D.play(buffered_anim)
    $AnimatedSprite2D.flip_h = buffered_flip or false
  state = state # weird, but we basically want to call the setter again
