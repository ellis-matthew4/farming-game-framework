extends CharacterBody2D

class_name NPC

@export var npc_name: String

enum DIRS { DOWN, UP, LEFT, RIGHT, NONE }
var facing = DIRS.DOWN

var snap = Globals.MAP_GRID_SIZE
var snap_point: Vector2
var moving: bool

# target represents the next space on the grid to move to
var target
# destination represents the actual coordinates the npc is traveling to
var destination: Vector2

var travel_stack = []
var schedule

signal turn(dir)
signal walk
signal reached

func _ready():
  var path = str("res://assets/schedules/", npc_name, ".json")
  var file = FileAccess.open(path, FileAccess.READ)
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
  
func _parse(data):
  var result = {}
  for key in data.keys():
    var positions = []
    for pos in data[key]:
      positions.append(Vector3(pos['x'], pos['y'], pos['z']))
    result[key] = positions
  return result

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
    if new_direction.x < 0:
      turn_anim(DIRS.LEFT)
    elif new_direction.x > 0:
      turn_anim(DIRS.RIGHT)
    elif new_direction.y > 0:
      turn_anim(DIRS.DOWN)
    elif new_direction.y < 0:
      turn_anim(DIRS.UP)
    target = point2d
  
func _physics_process(delta):
  set_collision_layer_value(2, !moving)
  var player = Globals.player
  if is_instance_valid(player):
    z_index = player.z_index + 1 if global_position.y > player.global_position.y else player.z_index - 1
  if !moving:
    $AnimatedSprite2D.play("down")
    $AnimatedSprite2D.stop()
  else:
    if target == null:
      if len(travel_stack) > 0:
        navigate_to_point(travel_stack.pop_front())
      else:
        moving = false
    elif global_position.distance_to(target) <= 4:
      global_position = target
      moving = false
      velocity = Vector2(0,0)
      navigate_to_point(travel_stack.pop_front())
    else:
      velocity = target_vec() * Globals.WALK_SPEED / 2
    move_and_slide()
    
func _on_clock_tick():
  var time = str(Globals.clock.time)
  if schedule.has(time):
    travel_stack.append_array(schedule[time])
    moving = true

func target_vec():
  return (target - global_position).normalized()

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

func gift(item: Consumable):
  item.consume()
  return "liked"