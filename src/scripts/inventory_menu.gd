extends ColorRect
enum { UP, DOWN, LEFT, RIGHT, SELF }

@onready var SlotScene = preload("res://scenes/Menus/InventorySlot.tscn")
@onready var InventoryGrid = get_node('VBoxContainer/Grid')
@onready var Cursor = get_node('Cursor')
var grid = Grid.new(Globals.unlocked_inventory_slots / 10, 10)
var can_change_focus = true

var parent_menu
var mouse_activity = false
var focused = false
var held_index = -1

signal cancel

func _ready():
  # load inventory
  var idx = 0
  for i in Globals.inventory:
    var slot = SlotScene.instantiate()
    InventoryGrid.add_child(slot)
    slot.from_item(i)
    slot.context = "inventory"
    if idx > Globals.unlocked_inventory_slots - 1:
      slot.lock()
    else:
      slot.mouse_activity.connect(self.defocus_current)
    idx += 1
    
func focus():
  _change_focus_inventory(1, 1)
  for slot in InventoryGrid.get_children():
    if not slot.locked:
      slot.context = "focused_inventory"
  await get_tree().create_timer(0.1).timeout
  focused = true
  
func defocus():
  _change_focus_inventory(grid.get_current(), -1)
  for slot in InventoryGrid.get_children():
    if not slot.locked:
      slot.context = "inventory"
  focused = false

func _process(delta):
  if focused:
    if Input.is_action_just_pressed("ux_left"):
      mouse_activity = false
      Cursor.mouse_active = false
      _change_focus_inventory(_get_neighbor(SELF), _get_neighbor(LEFT))
    elif Input.is_action_just_pressed("ux_right"):
      mouse_activity = false
      Cursor.mouse_active = false
      _change_focus_inventory(_get_neighbor(SELF), _get_neighbor(RIGHT))
    elif Input.is_action_just_pressed("ux_up"):
      mouse_activity = false
      Cursor.mouse_active = false
      _change_focus_inventory(_get_neighbor(SELF), _get_neighbor(UP))
    elif Input.is_action_just_pressed("ux_down"):
      mouse_activity = false
      Cursor.mouse_active = false
      _change_focus_inventory(_get_neighbor(SELF), _get_neighbor(DOWN))
    elif Input.is_action_just_pressed("player_cancel"):
      if Cursor.holding:
        var n = InventoryGrid.get_child(held_index)
        n.from_item(Cursor.item)
        Cursor.clear()
        held_index = -1
      else:
        emit_signal("cancel")
    elif (mouse_activity and Input.is_action_just_pressed("ux_left_click")) or Input.is_action_just_pressed("ux_select"):
      var idx = grid.get_current() - 1
      var n = InventoryGrid.get_child(idx)
      var item = n.item
      if not Cursor.holding:
        held_index = idx
      else:
        Globals.swap(idx, held_index)
      n.from_item(Cursor.item)
      Cursor.from_item(item)

func _change_focus_inventory(old, new):
  if old == -1 and new != 1:
    return
  if new > Globals.unlocked_inventory_slots or new < 1:
    if new == -1:
      InventoryGrid.get_child(old - 1).defocus()
      return
    print("ERR: INVALID INDEX _change_focus_inventory")
  InventoryGrid.get_child(old - 1).defocus()
  InventoryGrid.get_child(new - 1).focus()
  Cursor.align(InventoryGrid.get_child(new - 1))
  $VBoxContainer/Description/Label.text = str(InventoryGrid.get_child(new - 1).get_description())
  _wait_and_reset(0.125)
  
func defocus_current():
  if not mouse_activity:
    var id = grid.get_current()
    InventoryGrid.get_child(id - 1).defocus()
    mouse_activity = true
    Cursor.mouse_active = true
    focused = true
  var idx = 1
  for c in InventoryGrid.get_children():
    if c.color == Color.YELLOW:
      grid.i = idx
      return
    idx += 1
    
func _get_neighbor(direction):
  match(direction):
    UP:
      return grid.get_previous_row()
    DOWN:
      return grid.get_next_row()
    LEFT:
      return grid.get_previous()
    RIGHT:
      return grid.get_next()
    SELF:
      return grid.get_current()

func _wait_and_reset(timeout):
  can_change_focus = false
  await get_tree().create_timer(timeout).timeout
  can_change_focus = true
