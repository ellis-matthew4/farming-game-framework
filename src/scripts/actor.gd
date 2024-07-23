extends CharacterBody2D

class_name Actor

@onready var origin = global_position
@export var speed_mod = 16

enum states {IDLE, MOVING, NEXT, FINISHED, WANDERING}
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

func _physics_process(delta):
  match(state):
    states.IDLE:
      velocity = Vector2(0,0)
      if not travel_stack.is_empty():
        navigate_to_point(travel_stack.pop_front())
        state = states.MOVING
    states.MOVING:
      if _distance_to_target() <= 4:
        global_position = target
        velocity = Vector2(0,0)
        state = states.NEXT
      else:
        velocity = target_vec() * Globals.WALK_SPEED * speed_mod * delta
    states.NEXT:
      if travel_stack.is_empty():
        state = states.FINISHED
      else:
        navigate_to_point(travel_stack.pop_front())
        state = states.MOVING
    states.FINISHED:
      state = states.IDLE
  
  # Try to move based on velocity
  # The constant here should be as small as possible to prevent jitter.
  var test_vector = velocity.normalized() * 1
  if test_move(transform, test_vector):
    _force_realign()
  else:
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
