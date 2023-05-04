extends StaticBody2D

class_name GroundItem

@export var item_id: int = -1
var item: Item

func _ready():
	var ap = null
	for c in get_children():
		if c is AnimationPlayer:
			ap = c
	if ap != null:
		ap.play("float")
		
func _process(delta):
	if item == null and item_id > -1:
		print(item_id)
		item = ItemDatabase.get_item(item_id)
		create(item)

func create(i: Item):
	item = i
	$Sprite2D.texture = item.texture

func interact():
	if Globals.try_add_inventory(item):
		queue_free()

func _on_animation_player_animation_finished(anim_name):
	$AnimationPlayer.play(anim_name)
