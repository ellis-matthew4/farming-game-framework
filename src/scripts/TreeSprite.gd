extends Sprite2D

class_name TreeSprite

var player

func _ready():
  player = Globals.player()

func _process(_delta):
  if player == null:
    player = Globals.player()
  else:
    if player.global_position.y >= global_position.y:
      z_index = player.z_index - 1
    else:
      z_index = player.z_index + 1
