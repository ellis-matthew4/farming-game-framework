extends Control

var can_change_focus = true
var grid = Grid.new(4, 1)

func _ready():
  get_tree().paused = true
  focus(_get_current(), 0.01)

func _process(_delta):
  if Input.is_action_just_pressed("ux_down"):
    defocus(_get_current())
    focus(_get_next(), 0.125)
  elif Input.is_action_just_pressed("ux_up"):
    defocus(_get_current())
    focus(_get_prev(), 0.125)
  elif Input.is_action_just_pressed("player_interact"):
    match(grid.get_current()):
      1:	# Resume
        get_tree().paused = false
        Globals.menuLayer.menu_hide(self)
      2:	# Config
        pass
      3:	# Save
        pass
      4:	# Load
        pass
      _:
        print("ERR: PauseMenuIndexOutOfBounds: " + str(grid.get_current()))

func _get_next():
  return get_node("ColorRect/VBoxContainer/ColorRect" + str(grid.get_next()))
  
func _get_prev():
  return get_node("ColorRect/VBoxContainer/ColorRect" + str(grid.get_previous()))

func _get_current():
  return get_node("ColorRect/VBoxContainer/ColorRect" + str(grid.get_current()))

func focus(node, timeout):
  node.color = Color.DARK_GRAY
  _wait_and_reset(timeout)
  
func defocus(node):
  node.color = Color('#6a2a33')

func _wait_and_reset(timeout):
  can_change_focus = false
  await get_tree().create_timer(timeout).timeout
  can_change_focus = true
