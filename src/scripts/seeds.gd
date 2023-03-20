extends Consumable

class_name Seeds

var max_stages = 1
var product_id: int
var reharvestable: bool
var reharvest_stage: int

func _init(n: String, v: int, tx_path: String, stages: int, prd: int, rh: bool = false, rhs: int = 1):
	item_name = n
	value = v
	texture = load(tx_path)
	max_stages = stages
	product_id = prd
	reharvestable = rh
	reharvest_stage = rhs

func get_texture_as_sprite2D(stage):
	var tx = Sprite2D.new()
	tx.texture = texture
	tx.region_enabled = true
	tx.region_rect = Rect2(0, stage, Globals.map_grid_size, Globals.map_grid_size)
	tx.centered = true
	return tx

func get_product():
	return ItemDatabase.get_item(product_id)
