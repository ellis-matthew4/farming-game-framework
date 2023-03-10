extends Control

var index = 1
var max_index = 4
var can_change_focus = true

func _ready():
	get_tree().paused = true
	focus(_get_current(), 0.01)

func _process(delta):
	if Input.is_action_just_pressed("ux_down"):
		focus(_get_next(), 0.125)
	elif Input.is_action_just_pressed("ux_up"):
		focus(_get_prev(), 0.125)
	elif Input.is_action_just_pressed("player_interact"):
		match(index):
			1:	# Resume
				get_tree().paused = false
				Globals.menuLayer.menu_hide(self)
			2:	# Config
				pass
			3:	# Save
				pass
			4:	# Load
				pass

func _get_next():
	return get_node("ColorRect/VBoxContainer/ColorRect" + str(index + 1 if index < max_index else 1))
	
func _get_prev():
	return get_node("ColorRect/VBoxContainer/ColorRect" + str(index + 1 if index < max_index else 1))

func _get_current():
	return get_node("ColorRect/VBoxContainer/ColorRect" + str(index))

func focus(node, timeout):
	defocus(_get_current())
	node.color = Color.DARK_GRAY
	index = int(node.get_name().substr(9, -1))
	_wait_and_reset(timeout)
	
func defocus(node):
	node.color = Color('#6a2a33')

func _wait_and_reset(timeout):
	can_change_focus = false
	await get_tree().create_timer(timeout).timeout
	can_change_focus = true
