extends StaticBody2D

class_name Soil

var crop_sprite
var crop: Item
var tilled = false
var watered = false
var stage = 0
var quality = 1
@onready var soil_txt = preload("res://assets/soil.png")
@onready var soil_txt_w = preload("res://assets/soil_watered.png")

func _ready():
	$Sprite.offset = Vector2(Globals.MAP_GRID_SIZE / 2, Globals.MAP_GRID_SIZE / 2)
	$CollisionShape2D.position = Vector2(Globals.MAP_GRID_SIZE / 2, Globals.MAP_GRID_SIZE / 2)

func set_soil_texture(txt: Texture2D):
	$Sprite.texture = txt
	
func set_crop_texture(spr: Sprite2D):
	if is_instance_valid(spr):
		add_child(spr)
		crop_sprite = spr
		spr.offset = Vector2(Globals.MAP_GRID_SIZE / 2, Globals.MAP_GRID_SIZE / 2)
	else:
		crop_sprite.queue_free()

func hoe():
	set_soil_texture(soil_txt)
	tilled = true
	
func water():
	if tilled:
		set_soil_texture(soil_txt_w)
		watered = true
	
func sow(i: Seeds, s: int = 1):
	if tilled:
		set_crop_texture(i.get_texture_as_sprite2D(s))
		crop = i
		stage = s
		if crop == null:
			print("ERR: MISSING_CROP")

func hammer():
	set_soil_texture(null)
	
func axe():
	pass
	
func fertilize():
	quality = min(4, quality + 1)
	
func sickle():
	if crop.reharvestable:
		if stage > crop.reharvest_stage:
			set_crop_texture(crop.get_texture_as_sprite2D(crop.reharvest_stage))
			stage = crop.reharvest_stage
		else:
			set_crop_texture(null)
			crop = null
			crop_sprite = null
			stage = 0
	else:
		if stage == crop.max_stages:
			var item_to_drop = crop.get_product()
			Globals.try_add_inventory(item_to_drop) # replace with ground item
		set_crop_texture(null)
		crop = null
		crop_sprite = null
		stage = 0
		
func increment_stage():
	if crop != null:
		stage = min(crop.max_stages, stage + 1)
		
func crop_idx():
	return ItemDatabase.get_idx(crop)
	
func spawn_rock():
	pass
	
func spawn_branch():
	pass

func spawn_weed():
	pass
