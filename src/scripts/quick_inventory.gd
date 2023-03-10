extends Control

var focused_index = 1

func _ready():
	focus(_get_current(), 0.01)

func _process(delta):
	if Globals.can_accept_mw_input:
		if Input.is_action_just_released("ux_mwu"):
			focus(_get_prev(), 0.01)
		elif Input.is_action_just_released("ux_mwd"):
			focus(_get_next(), 0.01)
		elif Input.is_action_pressed("ux_left"):
			focus(_get_prev(), 0.125)
		elif Input.is_action_pressed("ux_right"):
			focus(_get_next(), 0.125)

func _get_next():
	return get_node("HBoxContainer/ColorRect" + str(focused_index + 1 if focused_index < 10 else 1))
	
func _get_prev():
	return get_node("HBoxContainer/ColorRect" + str(focused_index - 1 if focused_index > 1 else 10))
	
func _get_current():
	return get_node("HBoxContainer/ColorRect" + str(focused_index))

func _wait_and_reset(timeout):
	Globals.can_accept_mw_input = false
	await get_tree().create_timer(timeout).timeout
	Globals.can_accept_mw_input = true

func focus(node, timeout):
	defocus(_get_current())
	node.color = Color.YELLOW
	focused_index = int(node.get_name().substr(9, -1))
	_wait_and_reset(timeout)
	
func defocus(node):
	node.color = Color.from_string("#959595", Color.DARK_GRAY)
