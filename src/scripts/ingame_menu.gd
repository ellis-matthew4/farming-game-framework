extends Control

enum { UP, DOWN, LEFT, RIGHT, SELF }
@onready var MenuSelection = get_node('ColorRect/VBoxContainer/MenuSelection')
@onready var inventoryScene = preload("res://scenes/Menus/inventoryMenu.tscn")
@onready var MenuContainer = get_node('ColorRect/VBoxContainer')
var can_hide = false
var focused_menu = true
var can_change_focus = true
var menu_grid = Grid.new(1, 3)

var instanced_menu
var menu_id = 1

func _ready():
  instanced_menu = inventoryScene.instantiate()
  MenuContainer.add_child(instanced_menu)
  instanced_menu.cancel.connect(self._reclaim_focus)
  MenuSelection.get_child(0).color = Color.YELLOW
  instanced_menu.focus()
  await get_tree().create_timer(0.1).timeout
  can_hide = true
  
func _process(delta):
  if focused_menu:
    if Input.is_action_just_pressed("ux_select"):
      instanced_menu.focus()
      focused_menu = false
    elif Input.is_action_just_pressed("ux_left"):
      _change_focus_menu(_get_neighbor_menu(LEFT))
    elif Input.is_action_just_pressed("ux_right"):
      _change_focus_menu(_get_neighbor_menu(RIGHT))
    elif can_hide and (Input.is_action_just_pressed("ux_menu") or Input.is_action_just_pressed("player_cancel")):
      Globals.menuLayer.menu_hide(self)

func _get_neighbor_menu(direction):
  match(direction):
    LEFT:
      return menu_grid.get_previous()
    RIGHT:
      return menu_grid.get_next()
    SELF:
      return menu_grid.get_current()

func _change_focus_menu(id):
  if id > 3 or id < 1:
    print("ERR: INVALID INDEX _change_focus_menu")
  for c in MenuSelection.get_children():
    c.color = Color('#8f8f32')
  MenuSelection.get_child(id - 1).color = Color.YELLOW
  MenuContainer.remove_child(instanced_menu)
  instanced_menu.queue_free()
  match(id):
    1:
      instanced_menu = inventoryScene.instantiate()
    2:
      instanced_menu = inventoryScene.instantiate()
    3:
      instanced_menu = inventoryScene.instantiate()
  MenuContainer.add_child(instanced_menu)
  instanced_menu.cancel.connect(self._reclaim_focus)
  menu_id = id
  _wait_and_reset(0.125)
  
func _reclaim_focus():
  instanced_menu.defocus()
  focused_menu = true
  
func _wait_and_reset(timeout):
  can_change_focus = false
  await get_tree().create_timer(timeout).timeout
  can_change_focus = true
