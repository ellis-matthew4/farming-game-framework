extends Consumable

class_name Seeds

var max_stages = 1
var product_id: String
var reharvestable: bool
var reharvest_stage: int

func _init(n: String, v: int, tx_path: String, stages: int, prd: String, rh: bool = false, rhs: int = 1):
  item_name = n
  value = v
  texture = load(tx_path)
  max_stages = stages
  product_id = prd
  reharvestable = rh
  reharvest_stage = rhs
    
func _ready():
  description = str("Seeds to grow ", get_product().item_name, ". Takes ", max_stages, " days to grow.")
  if reharvestable:
    description += " Regrows after harvesting."
  

func get_texture_as_sprite2D(stage):
  stage = max(0, stage - 1)
  var tx = Sprite2D.new()
  tx.texture = texture
  tx.region_enabled = true
  tx.region_rect = Rect2(stage * Globals.MAP_GRID_SIZE, 0, Globals.MAP_GRID_SIZE, Globals.MAP_GRID_SIZE)
  tx.centered = true
  return tx

func get_product():
  return ItemDatabase.get_item(product_id)
