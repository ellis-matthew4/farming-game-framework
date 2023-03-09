extends Control

enum { UP, DOWN, LEFT, RIGHT }
@onready var InventoryGrid = get_node('ColorRect/VBoxContainer/Inventory/VBoxContainer/Grid')
@onready var MenuSelection = get_node('ColorRect/VBoxContainer/MenuSelection')
var can_hide = false
var focused_menu_index = 1
var focused_inventory_index = 1
var focused_menu = 0
var menu_count = 3
var can_change_focus = true

func _ready():
	_change_focus_menu(1, 1)
	await get_tree().create_timer(0.1).timeout
	can_hide = true
	
func _process(delta):
	if focused_menu == 0:
		if Input.is_action_just_pressed("player_interact"):
			focused_menu = 1
			if focused_menu_index == 1:
				_change_focus_inventory(1, 1)
		elif Input.is_action_just_pressed("ux_left"):
			_change_focus_menu(focused_menu_index, _get_neighbor_menu(LEFT))
		elif Input.is_action_just_pressed("ux_right"):
			_change_focus_menu(focused_menu_index, _get_neighbor_menu(RIGHT))
		elif can_hide and (Input.is_action_just_pressed("ux_menu") or Input.is_action_just_pressed("player_cancel")):
			Globals.player.menu_hide(self)
	if focused_menu == 1:
		if Input.is_action_just_pressed("ux_left"):
			_change_focus_inventory(focused_inventory_index, _get_neighbor(LEFT))
		elif Input.is_action_just_pressed("ux_right"):
			_change_focus_inventory(focused_inventory_index, _get_neighbor(RIGHT))
		elif Input.is_action_just_pressed("ux_up"):
			_change_focus_inventory(focused_inventory_index, _get_neighbor(UP))
		elif Input.is_action_just_pressed("ux_down"):
			_change_focus_inventory(focused_inventory_index, _get_neighbor(DOWN))
		elif Input.is_action_just_pressed("player_cancel"):
			focused_menu = 0
			_change_focus_inventory(focused_inventory_index, -1)
		
func _get_neighbor(direction):
	var maxv = Globals.unlocked_inventory_slots
	var slot_number = focused_inventory_index
	match(direction):
		UP:
			var new = slot_number - 10
			return new if new > 0 else new + maxv
		DOWN:
			var new = slot_number + 10
			return new if new < maxv else new - maxv
		LEFT:
			return slot_number - 1 if slot_number > 1 else maxv
		RIGHT:
			return slot_number + 1 if slot_number < maxv else 1

func _get_neighbor_menu(direction):
	var maxv = menu_count
	var slot_number = focused_menu_index
	match(direction):
		LEFT:
			return slot_number - 1 if slot_number > 1 else maxv
		RIGHT:
			return slot_number + 1 if slot_number < maxv else 1

func _change_focus_inventory(old, new):
	if new > Globals.unlocked_inventory_slots or new < 1:
		if new == -1:
			InventoryGrid.get_child(old - 1).color = Color.WHITE
			return
		print("ERR: INVALID INDEX _change_focus_inventory")
	InventoryGrid.get_child(old - 1).color = Color.WHITE
	InventoryGrid.get_child(new - 1).color = Color.GRAY
	focused_inventory_index = new
	_wait_and_reset(0.125)

func _change_focus_menu(old, new):
	if new > 3 or new < 1:
		print("ERR: INVALID INDEX _change_focus_menu")
	MenuSelection.get_child(old - 1).color = Color('#8f8f32')
	MenuSelection.get_child(new - 1).color = Color.YELLOW
	match(new):
		1:
			$ColorRect/VBoxContainer/Inventory.show()
			$ColorRect/VBoxContainer/Stats.hide()
			$ColorRect/VBoxContainer/Friendship.hide()
		2:
			$ColorRect/VBoxContainer/Inventory.hide()
			$ColorRect/VBoxContainer/Stats.show()
			$ColorRect/VBoxContainer/Friendship.hide()
		3:
			$ColorRect/VBoxContainer/Inventory.hide()
			$ColorRect/VBoxContainer/Stats.hide()
			$ColorRect/VBoxContainer/Friendship.show()
	focused_menu_index = new
	_wait_and_reset(0.125)
	
func _wait_and_reset(timeout):
	can_change_focus = false
	await get_tree().create_timer(timeout).timeout
	can_change_focus = true
