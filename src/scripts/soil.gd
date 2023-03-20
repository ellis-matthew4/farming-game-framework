extends Sprite2D

func _ready():
	offset = Vector2(Globals.map_grid_size / 2, Globals.map_grid_size / 2)

func set_soil_texture(txt: Texture2D):
	texture = txt
	
func set_crop_texture(spr: Sprite2D):
	if is_instance_valid(spr):
		add_child(spr)
		spr.offset = Vector2(Globals.map_grid_size / 2, Globals.map_grid_size / 2)
	else:
		get_child(0).queue_free()

# TODO: Move tool effects to this class
