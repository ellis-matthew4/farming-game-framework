extends Node2D

var item: Item
var mouse_active = false
var holding = false

func _process(delta):
  if mouse_active:
    global_position = get_global_mouse_position()
  
func from_index(i: int):
  var i_item = Globals.inventory[i]
  if i == null or i_item == null:
    clear()
    return
  item = ItemDatabase.get_item(i_item[0])
  var quantity = i_item[1]
  set_texture(item.texture)
  var text: String = "" if quantity <= 1 else str(quantity)
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
