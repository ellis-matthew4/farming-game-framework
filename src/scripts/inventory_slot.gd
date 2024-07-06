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
  var texture = i.texture
  set_texture(texture, get_region_rect())
  var text = "" if item.quantity <= 1 else str(item.quantity)
  set_label(text)
  
func get_region_rect():
  if item.has_method("render_region"):
    return item.render_region(0)
  else:
    var dim = item.texture.get_width()
    return Rect2(0,0,dim, dim)
  
func clear():
  set_texture(null)
  set_label("")
  item = null

func set_texture(tx: Texture, r: Rect2 = Rect2(0, 0, Globals.MAP_GRID_SIZE, Globals.MAP_GRID_SIZE)):
  var atlas = AtlasTexture.new()
  atlas.atlas = tx
  atlas.region = r
  $TextureRect.texture = atlas
  
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
  if !locked and context == 'focused_inventory':
    focus()
    emit_signal('mouse_activity')
    
func _on_area_2d_mouse_exited():
  if !locked and context == 'focused_inventory':
    defocus()
