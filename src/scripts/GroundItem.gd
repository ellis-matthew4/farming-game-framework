extends StaticBody2D

class_name GroundItem

@export var item_id: String = ''
var item: Item
var can_interact: bool = false

func _ready():
  var ap = null
  for c in get_children():
    if c is AnimationPlayer:
      ap = c
  if ap != null:
    ap.play("float")
  await get_tree().create_timer(0.25).timeout
  if self in Globals.player.get_node('PickUpArea').get_overlapping_bodies():
    interact()
  can_interact = true
    
func _process(delta):
  if item == null and item_id != '':
    create(item_id)

func create(i: String):
  item_id = i
  item = ItemDatabase.get_item(i)
  $Sprite2D.texture = item.texture

func interact():
  if can_interact and Globals.try_add_inventory(item_id):
    Globals.repopulate_quick_inventory()
    queue_free()

func _on_animation_player_animation_finished(anim_name):
  $AnimationPlayer.play(anim_name)
