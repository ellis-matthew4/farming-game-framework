extends Consumable

class_name Seeds

var max_stages = 1
var product_id: String
var reharvestable: bool
var reharvest_stage: int

var stages_texture

func _init(n: String, v: int, tx_path: String, stages: int, prd: String, stx, rh: bool = false, rhs: int = 1):
  item_name = n
  value = v
  texture = load(tx_path)
  max_stages = stages
  product_id = prd
  reharvestable = rh
  reharvest_stage = rhs
  stages_texture = load(stx)
    
func prepare_rendered_data():
  description = str("Seeds to grow ", get_product().item_name, ". Takes ", max_stages, " days to grow.")
  if reharvestable:
    description += " Regrows after harvesting."
  
# TODO: Ignore image_stage 0, let that be the held item sprite
func get_texture_as_sprite2D(stage):
  stage = max(0, stage - 1)
  var max_image_stages = stages_texture.get_width() / Globals.MAP_GRID_SIZE
  var image_stage_percentage = (stage * 1.0) / max_image_stages
  var image_stage = max_image_stages * image_stage_percentage
  var tx = Sprite2D.new()
  tx.texture = stages_texture
  tx.offset = Vector2(Globals.MAP_GRID_SIZE/2, Globals.MAP_GRID_SIZE/2)
  tx.region_enabled = true
  tx.region_rect = render_region(image_stage)
  tx.centered = true
  return tx
  
func render_region(stage: int):
  return Rect2(stage * Globals.MAP_GRID_SIZE, 0, Globals.MAP_GRID_SIZE, Globals.MAP_GRID_SIZE)

func get_product():
  return ItemDatabase.get_item(product_id)
