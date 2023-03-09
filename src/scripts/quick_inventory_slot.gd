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
			get_node(focus_previous).grab_focus()
			_wait_and_reset(0.01)
		elif Input.is_action_just_released("ui_mwd"):
			get_node(focus_next).grab_focus()
			_wait_and_reset(0.01)
		elif Input.is_action_pressed("ux_left"):
			get_node(focus_previous).grab_focus()
			_wait_and_reset(0.125)
		elif Input.is_action_pressed("ux_right"):
			get_node(focus_next).grab_focus()
			_wait_and_reset(0.125)
	

func _on_focus_entered():
	color = Color.YELLOW
	focused = true

func _on_focus_exit():
	color = Color.from_string("#959595", Color.DARK_GRAY)
	focused = false

func _wait_and_reset(timeout):
	Globals.can_accept_mw_input = false
	await get_tree().create_timer(timeout).timeout
	Globals.can_accept_mw_input = true
