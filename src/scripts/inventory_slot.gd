extends ColorRect

var item: Item
var locked = false

func from_item(i: Item):
	if i == null:
		return
	item = i
	set_texture(i.texture)
	var text = "" if item.quantity <= 1 else str(item.quantity)
	set_label(text)

func set_texture(tx: Texture):
	$TextureRect.texture = tx
	
func set_label(tx: String):
	$Label.text = tx
	
func focus():
	color = Color.YELLOW
	
func defocus():
	color = Color("#959595")

func lock():
	locked = true
	color = Color.DARK_SLATE_GRAY
