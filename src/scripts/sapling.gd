extends Consumable

class_name Sapling

var max_stages = 1
var product_id: String
var reharvestable: bool
var reharvest_stage: int
var season: int

var stages_texture

func _init(n: String, v: int, tx_path: String, stages: int, prd: String, stx, sesn: int = 0,rhs: int = 1):
  item_name = n
  value = v
  texture = load(tx_path)
  max_stages = stages
  product_id = prd
  reharvestable = true
  reharvest_stage = rhs
  season = sesn
  stages_texture = load(stx)
    
func prepare_rendered_data():
  description = str("Seeds to grow ", get_product().item_name, ". Takes ", max_stages, " days to grow.")
  if reharvestable:
    description += " Regrows after harvesting."

func get_texture_as_sprite2D(stage):
  stage = stage if Globals.calendar.season == season else min(stage, max_stages - 1)
  var max_image_stages = (stages_texture.get_width() / (Globals.MAP_GRID_SIZE*3)) -1
  var image_stage_percentage = (stage * 1.0) / max_stages
  var image_stage = floor(max_image_stages * image_stage_percentage)
  print(stage, '/', max_stages, ":", image_stage, "/", max_image_stages, ":", image_stage_percentage, "%")
  var tx = TreeSprite.new()
  tx.texture = stages_texture
  tx.offset = Vector2(Globals.MAP_GRID_SIZE/2, -Globals.MAP_GRID_SIZE/2)
  tx.region_enabled = true
  tx.region_rect = render_region(image_stage)
  tx.centered = true
  return tx
  
func render_region(stage):
  return Rect2(stage * Globals.MAP_GRID_SIZE*3, 0, Globals.MAP_GRID_SIZE*3, Globals.MAP_GRID_SIZE*3)
  
func get_product():
  return ItemDatabase.get_item(product_id)
