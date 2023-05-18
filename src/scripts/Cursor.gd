extends Node2D

var item: Item
var mouse_active = false
var holding = false

func _process(delta):
	if mouse_active:
		global_position = get_global_mouse_position()

func from_item(i: Item):
	if i == null:
		clear()
		return
	item = i
	set_texture(i.texture)
	var text: String = "" if item.quantity <= 1 else str(item.quantity)
	set_label(text)
	holding = true
	
func clear():
	set_texture(null)
	set_label("")
	item = null
	holding = false

func set_texture(tx: Texture):
	$ColorRect/TextureRect.texture = tx
	
func set_label(tx: String):
	$ColorRect/Label.text = tx

func align(node: Node):
	global_position = node.global_position
