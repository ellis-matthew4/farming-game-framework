extends CanvasLayer

var ingame_menu = preload("res://scenes/Menus/ingame_menu.tscn")
var quick_inv = preload("res://scenes/Menus/quick_inventory.tscn")
var pauseMenu = preload("res://scenes/Menus/pause_menu.tscn")
var debug = preload("res://scenes/Menus/debug.tscn")
var debugging = false
var reset_timer = false

func _ready():
	Globals.menuLayer = self

func debug_menu():
	if not reset_timer:
		if debugging:
			debugging = false
			get_node("Debug").queue_free()
		else:
			debugging = true
			add_child(debug.instantiate())
			reset(0.125)

func ig_menu():
	menu_show(ingame_menu.instantiate())
	
func pause_menu():
	menu_show(pauseMenu.instantiate())

func menu_show(menu):
	Globals.movement_blocked = true
	$quick_inventory.hide()
	add_child(menu)
	
func menu_hide(menu):
	Globals.movement_blocked = false
	$quick_inventory.show()
	menu.queue_free()

func reset(timeout):
	reset_timer = true
	await get_tree().create_timer(timeout).timeout
	reset_timer = false
