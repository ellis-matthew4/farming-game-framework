extends Control

var grid = Grid.new(1, 10)
@onready var SlotScene = preload("res://scenes/Menus/InventorySlot.tscn")

signal focus_change
signal populated

func _ready():
	_populate()
	await self.populated
	focus(_get_current(), 0.01)

func _process(delta):
	if Globals.can_accept_mw_input:
		if Globals.keyboard:
			if Input.is_action_just_released("ux_mwu"):
				defocus(_get_current())
				focus(_get_prev(), 0.01)
			elif Input.is_action_just_released("ux_mwd"):
				defocus(_get_current())
				focus(_get_next(), 0.01)
		else:
			if Input.is_action_pressed("ux_left"):
				defocus(_get_current())
				focus(_get_prev(), 0.125)
			elif Input.is_action_pressed("ux_right"):
				defocus(_get_current())
				focus(_get_next(), 0.125)

func _get_next():
	return $HBoxContainer.get_child(grid.get_next() - 1)
	
func _get_prev():
	return $HBoxContainer.get_child(grid.get_previous() - 1)
	
func _get_current():
	return $HBoxContainer.get_child(grid.get_current() - 1)
	
func _populate():
	_depopulate()
	var inv = Globals.inventory
	for i in range(0, 10):
		var slot = SlotScene.instantiate()
		$HBoxContainer.add_child(slot)
		slot.from_item(Globals.inventory[i])
	emit_signal("populated")

func _depopulate():
	for c in $HBoxContainer.get_children():
		$HBoxContainer.remove_child(c)
		c.queue_free()

func _wait_and_reset(timeout):
	Globals.can_accept_mw_input = false
	await get_tree().create_timer(timeout).timeout
	Globals.can_accept_mw_input = true

func focus(node, timeout):
	node.focus()
	_wait_and_reset(timeout)
	emit_signal("focus_change")
	
func defocus(node):
	node.defocus()

func focused_index():
	return grid.get_i()
