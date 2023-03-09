extends ColorRect

var index
var focused = false

func _ready():
	set_focus_mode(Control.FOCUS_ALL)
	index = int(get_name().substr(9, -1))
	if index == 1:
		grab_focus()
		_on_focus_entered()
	self.focus_entered.connect(_on_focus_entered.bind())
	self.focus_exited.connect(_on_focus_exit.bind())
	
func _process(delta):
	if focused and Globals.can_accept_mw_input:
		if Input.is_action_just_released("ui_mwu"):
			get_node("../ColorRect" + str(_get_previous_index())).grab_focus()
			Globals.can_accept_mw_input = false
			_wait_and_reset()
		elif Input.is_action_just_released("ui_mwd"):
			get_node("../ColorRect" + str(_get_next_index())).grab_focus()
			Globals.can_accept_mw_input = false
			_wait_and_reset()
	

func _on_focus_entered():
	color = Color.YELLOW
	focused = true

func _on_focus_exit():
	color = Color.from_string("#959595", Color.DARK_GRAY)
	focused = false

func _wait_and_reset():
	await get_tree().create_timer(0.01).timeout
	Globals.can_accept_mw_input = true

func _get_next_index():
	if index == 10:
		return 1
	else:
		return index + 1

func _get_previous_index():
	if index == 1:
		return 10
	else:
		return index - 1
