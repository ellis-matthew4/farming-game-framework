extends CharacterBody2D

class_name Actor

@onready var origin = global_position:
  set(new):
    origin = new
    _set_bounds()
var bounds
@export var speed_mod = 16
@export var care_about_collision = false

# This value should be as low as possible to avoid jitteriness
const SNAP_DIST = 1

enum states {IDLE, MOVING, NEXT, FINISHED}
var state = states.IDLE:
  set(new):
    previous_state = state
    state = new
    emit_signal('state_change', new)
    
var previous_state

enum DIRS { DOWN, UP, LEFT, RIGHT, NONE }
var facing = DIRS.DOWN

# target represents the next space on the grid to move to
var target
var travel_stack = []

signal state_change(state)
signal finished

func _ready():
  _set_bounds()
  add_to_group('Actor')

func _physics_process(delta):
  if state == states.IDLE:
    velocity = Vector2(0,0)
    if not travel_stack.is_empty():
      navigate_to_point(travel_stack.pop_front())
      state = states.MOVING
  if state == states.MOVING:
    if _distance_to_target() <= SNAP_DIST:
      global_position = target
      velocity = Vector2(0,0)
      state = states.NEXT
    else:
      velocity = target_vec() * Globals.WALK_SPEED * speed_mod * delta
  if state == states.NEXT:
    if travel_stack.is_empty():
      state = states.FINISHED
    else:
      navigate_to_point(travel_stack.pop_front())
      state = states.MOVING
  if state == states.FINISHED:
    emit_signal('finished')
    state = states.IDLE
  
  # Try to move based on velocity
  # The constant here should be as small as possible to prevent jitter.
  var test_vector = velocity.normalized() * 1
  if care_about_collision:
    if test_move(transform, test_vector):
      travel_stack = []
      _force_realign()
      velocity = Vector2(0,0)
      state = states.IDLE
  move_and_slide()
    
func _distance_to_target():
  return global_position.distance_to(target)
    
func _force_realign():
  state = states.IDLE
  global_position = Vector2(
    snappedi(global_position.x, Globals.MAP_GRID_SIZE),
    snappedi(global_position.y, Globals.MAP_GRID_SIZE)
  )

func navigate_to_point(point):
  if point == null:
    state = states.IDLE
    return
  var method = point.z
  var point2d = Vector2(point.x, point.y)
  if method == 1:
    target = point2d
    global_position = point2d
  elif method == 0:
    var new_direction = (point2d - global_position).normalized()
    handle_turn(new_direction)
    target = point2d
  elif method == 2:
    handle_turn((point2d))
      
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
  facing = dir
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

func target_vec():
  return (target - global_position).normalized()
  
func _set_bounds():
  bounds = [
    Vector2(origin.x - Globals.MAP_GRID_SIZE, global_position.y - Globals.MAP_GRID_SIZE),
    Vector2(origin.x + Globals.MAP_GRID_SIZE, global_position.y + Globals.MAP_GRID_SIZE),
  ]
  
