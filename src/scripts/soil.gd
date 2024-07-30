extends StaticBody2D

class_name Soil

var crop_sprite
var crop: Item
var tilled = false
var watered = false
var stage = 0
var quality = 1
@onready var soil_txt = preload("res://assets/tiles/soil.png")
@onready var soil_txt_w = preload("res://assets/tiles/soil_watered.png")
@onready var float_item = preload("res://scenes/float_item.tscn")

var snap = Globals.MAP_GRID_SIZE

func _ready():
  $Sprite.offset = Vector2(Globals.MAP_GRID_SIZE / 2, Globals.MAP_GRID_SIZE / 2)
  $CollisionShape2D.position = Vector2(Globals.MAP_GRID_SIZE / 2, Globals.MAP_GRID_SIZE / 2)

func set_soil_texture(txt: Texture2D):
  $Sprite.texture = txt
  
func set_crop_texture(spr: Sprite2D):
  if is_instance_valid(spr):
    add_child(spr)
    crop_sprite = spr
  else:
    crop_sprite.queue_free()

func hoe():
  if crop == null:
    set_soil_texture(soil_txt)
    tilled = true
  
func water():
  if tilled:
    set_soil_texture(soil_txt_w)
    watered = true
  
func sow(i, s: int = 1):
  print('sowing ', i.key)
  if tilled:
    set_crop_texture(i.get_texture_as_sprite2D(s))
    crop = i
    stage = s
    if crop == null:
      print("ERR: MISSING_CROP")
    if crop is Sapling:
      solid()
      set_soil_texture(null)
  if i and i.key in ['branch', 'rock', 'weed']:
    crop = i
    stage = s
    solid()
    set_soil_texture(null)
    set_crop_texture(i.get_texture_as_sprite2D(s))

func hammer():
  set_soil_texture(null)
  if crop and crop.key == 'rock':
    set_crop_texture(null)
    crop = null
    crop_sprite = null
    nonsolid()
    var floater = float_item.instantiate()
    floater.create("stone")
    Globals.add_to_dynamic_layer(floater, global_position + Vector2(snap/2, snap/2))
  
func axe():
  if crop and crop.key == 'branch':
    set_crop_texture(null)
    crop = null
    crop_sprite = null
    nonsolid()
    var floater = float_item.instantiate()
    floater.create("lumber")
    Globals.add_to_dynamic_layer(floater, global_position + Vector2(snap/2, snap/2))
  
func fertilize():
  quality = min(4, quality + 1)
  
func interact():
  if crop is Sapling:
    # assume reharvestable
    if stage >= crop.max_stages:
      set_crop_texture(null)
      set_crop_texture(crop.get_texture_as_sprite2D(crop.reharvest_stage))
      stage = crop.reharvest_stage
      var count_to_drop = (randi() % 3) + 1
      var item_to_drop = crop.get_product()
      var origin = Vector2(snap/2, snap/2)
      var offsets = [
        origin + Vector2(Globals.MAP_GRID_SIZE, 0), 
        origin + Vector2(-Globals.MAP_GRID_SIZE, 0), 
        Vector2(0, Globals.MAP_GRID_SIZE)
      ]
      for i in range(0, count_to_drop):
        var floater = float_item.instantiate()
        floater.create(item_to_drop)
        Globals.add_to_dynamic_layer(floater, global_position + offsets[i])
        floater.z_index = Globals.player().z_index + 1
      return true
  return false
      
func sickle():
  if crop == null or crop is Sapling:
    return
  if crop and crop.key == 'weed':
    set_crop_texture(null)
    crop = null
    crop_sprite = null
    nonsolid()
    var floater = float_item.instantiate()
    floater.create("thatch")
    Globals.add_to_dynamic_layer(floater, global_position + Vector2(snap/2, snap/2))
    return
  if crop.reharvestable:
    if stage >= crop.reharvest_stage:
      set_crop_texture(crop.get_texture_as_sprite2D(crop.reharvest_stage))
      stage = crop.reharvest_stage
    else:
      set_crop_texture(null)
      crop = null
      crop_sprite = null
      stage = 0
  else:
    if stage == crop.max_stages:
      var item_to_drop = crop.product_id
      var floater = float_item.instantiate()
      floater.create(item_to_drop)
      Globals.add_to_dynamic_layer(floater, global_position + Vector2(snap/2, snap/2))
    set_crop_texture(null)
    crop = null
    crop_sprite = null
    stage = 0
    
func increment_stage():
  if crop != null:
    stage = min(crop.max_stages, stage + 1)
    
func crop_idx():
  if is_instance_valid(crop):
    print('crop.key ', crop.key)
    return crop.key
  else:
    return ''
    
func solid():
  set_collision_layer_value(2, true)

func nonsolid():
  set_collision_layer_value(2, false)
  
func spawn_rock():
  sow(ItemDatabase.get_item("rock"), 1)
  
func spawn_branch():
  sow(ItemDatabase.get_item("branch"), 1)
  pass

func spawn_weed():
  sow(ItemDatabase.get_item("weed"), 1)

func spawn_sapling():
  pass
