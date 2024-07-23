extends CharacterBody2D

class_name NPC

@export var npc_name: String
@export var can_marry: bool
@export var spouse: bool
@export var birthday: String # expects SEASON/DAY

var birth_month
var birth_day

enum DIRS { DOWN, UP, LEFT, RIGHT, NONE }
var facing = DIRS.DOWN

var moving: bool
var in_dialog = false

var wandering = false
var origin
var rto_tick = 360
var bounds
# target represents the next space on the grid to move to
var target

var travel_stack = []
var schedule = {}

var buffered_anim
var buffered_flip
var event_mode = false

signal turn(dir)
signal walk
signal reached
signal finished_traveling

func _ready():
  origin = global_position
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
    
func set_event_mode(mode):
  event_mode = mode
  
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
  velocity = Vector2(0,0)
  moving = false
  for t in schedule.keys():
    if int(t) > Globals.clock.time:
      var pos = schedule[t].back()
      global_position = Vector2(pos.x, pos.y)
      origin = global_position
      return
  global_position = origin
  
func return_to_origin_tick():
  var prev
  for t in schedule.keys():
    if int(t) > Globals.clock.time:
      return int(t) - 10

func navigate_to_point(point):
  if point == null:
    moving = false
    return
  moving = true
  var method = point.z
  var point2d = Vector2(point.x, point.y)
  if method == 1:
    target = point2d
    global_position = point2d
  elif method == 0:
    var current_direction = dir_to_vec(facing)
    var new_direction = (point2d - global_position).normalized()
    handle_turn(new_direction)
    target = point2d
  elif method == 2:
    handle_turn((point2d))
  
func _physics_process(delta):
  if in_dialog:
    velocity = Vector2(0,0)
    $AnimatedSprite2D.stop()
    move_and_slide()
    return
  set_collision_layer_value(2, !moving)
  var player = Globals.player
  if is_instance_valid(player):
    z_index = player.z_index + 1 if global_position.y > player.global_position.y else player.z_index - 1
    z_index = 100
  if !moving:
    $AnimatedSprite2D.stop()
  else:
    if target == null:
      if len(travel_stack) > 0:
        navigate_to_point(travel_stack.pop_front())
    elif global_position.distance_to(target) <= 4:
      global_position = target
      moving = false
      velocity = Vector2(0,0)
      if travel_stack.size() > 0:
        navigate_to_point(travel_stack.pop_front())
      else:
        if !wandering:
          emit_signal('finished_traveling')
          if not event_mode:
            wandering = true
            origin = global_position
            _set_bounds()
          rto_tick = return_to_origin_tick()
    else:
      velocity = target_vec() * Globals.WALK_SPEED / 2
    move_and_slide()
  
func _set_bounds():
    bounds = [
      Vector2(origin.x - Globals.MAP_GRID_SIZE, global_position.y - Globals.MAP_GRID_SIZE),
      Vector2(origin.x + Globals.MAP_GRID_SIZE, global_position.y + Globals.MAP_GRID_SIZE),
    ]
    
func _already_there(pos):
  return global_position == Vector2(pos.x, pos.y)
    
func _on_clock_tick():
  var time = str(Globals.clock.time)
  if schedule.has(time):
    if not _already_there(schedule[time].back()):
      travel_stack.append_array(schedule[time])
      moving = true
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
    moving = true
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
    moving = true

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
  var vec = (Globals.player.global_position - global_position).normalized()
  buffered_anim = $AnimatedSprite2D.animation
  buffered_flip = $AnimatedSprite2D.flip_h
  handle_turn(vec)

func dir_to_vec(dir):
  match(dir):
    DIRS.DOWN:
      return Vector2(0,1)
    DIRS.UP:
      return Vector2(0,-1)
    DIRS.LEFT:
      return Vector2(-1,0)
    DIRS.RIGHT:
      return Vector2(1,0)
    _:
      print("INVALID NPC DIRECTION ", dir)
      
func handle_turn(new_direction):
  if new_direction.x < 0:
    turn_anim(DIRS.LEFT)
  elif new_direction.x > 0:
    turn_anim(DIRS.RIGHT)
  elif new_direction.y > 0:
    turn_anim(DIRS.DOWN)
  elif new_direction.y < 0:
    turn_anim(DIRS.UP)
      
func turn_anim(dir):
  $AnimatedSprite2D.flip_h = (dir == DIRS.RIGHT)
  match(dir):
    DIRS.DOWN:
      $AnimatedSprite2D.play("down")
    DIRS.UP:
      $AnimatedSprite2D.play("up")
    DIRS.LEFT, DIRS.RIGHT:
      $AnimatedSprite2D.play("side")
    _:
      print("BAD ANIM KEY", dir)

func gift(item: Item):
  item.quantity -= 1
  return Globals.affection_manager.gift_affection(self, ItemDatabase.get_id(item))

func is_birthday():
  return Globals.calendar.season == birth_month and Globals.calendar.day == birth_day

func end_dialog():
  in_dialog = false
  if buffered_anim:
    $AnimatedSprite2D.play(buffered_anim)
  $AnimatedSprite2D.flip_h = buffered_flip or false
