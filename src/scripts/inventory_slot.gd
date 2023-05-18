extends ColorRect

var item: Item
var locked = false
var context

signal mouse_activity

func from_item(i: Item):
	if i == null:
		clear()
		return
	item = i
	set_texture(i.texture)
	var text = "" if item.quantity <= 1 else str(item.quantity)
	set_label(text)
	
func clear():
	set_texture(null)
	set_label("")
	item = null

func set_texture(tx: Texture):
	$TextureRect.texture = tx
	
func set_label(tx: String):
	$Label.text = tx
	
func get_description():
	if item == null:
		return ""
	else:
		return item.description
	
func focus():
	color = Color.YELLOW
	
func defocus():
	color = Color("#959595")

func lock():
	locked = true
	color = Color.DARK_SLATE_GRAY

func _on_area_2d_mouse_entered():
	if !locked and context == 'inventory':
		focus()
		emit_signal('mouse_activity')
		
func _on_area_2d_mouse_exited():
	if !locked and context == 'inventory':
		defocus()
