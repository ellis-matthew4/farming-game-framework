extends CanvasLayer

var ingame_menu = preload("res://scenes/Menus/ingame_menu.tscn")
var quick_inv = preload("res://scenes/Menus/quick_inventory.tscn")

func _ready():
	Globals.menuLayer = self

func menu():
	Globals.movement_blocked = true
	$quick_inventory.hide()
	add_child(ingame_menu.instantiate())
	
func menu_hide(menu):
	Globals.movement_blocked = false
	$quick_inventory.show()
	menu.queue_free()
