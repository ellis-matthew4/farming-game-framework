extends Control

var grid = Grid.new(1, 10)

func _ready():
	_populate()
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
	return get_node("HBoxContainer/ColorRect" + str(grid.get_next()))
	
func _get_prev():
	return get_node("HBoxContainer/ColorRect" + str(grid.get_previous()))
	
func _get_current():
	return get_node("HBoxContainer/ColorRect" + str(grid.get_current()))
	
func _populate():
	var inv = Globals.inventory
	for i in range(0, 10):
		if i < len(inv):
			get_node("HBoxContainer/ColorRect" + str(i + 1)).get_children()[0].texture = inv[i].texture

func _depopulate():
	for i in range(1, 11):
		var n = get_node("HBoxContainer/ColorRect" + str(i))
		var c = n.get_children()[0]
		n.remove_child(c)

func _wait_and_reset(timeout):
	Globals.can_accept_mw_input = false
	await get_tree().create_timer(timeout).timeout
	Globals.can_accept_mw_input = true

func focus(node, timeout):
	node.color = Color.YELLOW
	_wait_and_reset(timeout)
	
func defocus(node):
	node.color = Color.from_string("#959595", Color.DARK_GRAY)

func focused_index():
	return grid.get_i()
