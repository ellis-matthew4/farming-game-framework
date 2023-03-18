extends Sprite2D

func _ready():
	offset = Vector2(Globals.map_grid_size / 2, Globals.map_grid_size / 2)
	$Crop.offset = Vector2(Globals.map_grid_size / 2, Globals.map_grid_size / 2)

func set_soil_texture(txt: Texture2D):
	texture = txt
	
func set_crop_texture(txt: Texture2D):
	$Crop.texture = txt
