@tool
extends Node2D

@export var process: bool = false

@export var skin_color: Color = Color('e9c8bc')
@export var eye_color: Color = Color.BLUE
@export var shirt_color: Color = Color.AQUAMARINE
@export var pants_color: Color = Color.BURLYWOOD
@export var shoes_color: Color = Color.BURLYWOOD
@export var hair_color: Color = Color.BROWN

var exposed_eye_styles = ["basic", "brows", "lashes", "moist", "moist_brow", "moist_lashes"]
@export_enum ("basic", "brows", "lashes", "moist", "moist_brow", "moist_lashes") var eye_style: String = "basic"
var exposed_shirt_styles = ["short_sleeve_tee", "longsleeve"]
@export_enum ("short_sleeve_tee", "longsleeve") var shirt_style: String = "short_sleeve_tee"
var exposed_hair_styles = ["combed", "pompadour"]
@export_enum ("combed", "pompadour") var hair_style: String = "combed"
var exposed_pants_styles = ["shorts", "pants"]
@export_enum ("shorts", "pants") var pants_style: String = "shorts"
var exposed_shoe_styles = ["sneakers"]
@export_enum ("sneakers") var shoe_style: String = "sneakers"

@export_enum ("up", "down", "side") var animation: String = "down"
@export var playing: bool = false 
@export var frame: int = 0
@export var flip_h: bool = false:
  set(value):
    flip_h = value
    for c in get_children():
      c.flip_h = value

func _process(delta):
  if not process:
    return
  if $body.modulate != skin_color:
    $body.modulate = skin_color
  if $eyes.modulate != eye_color:
    $eyes.modulate = eye_color
  if $shirt.modulate != shirt_color:
    $shirt.modulate = shirt_color
  if $pants.modulate != pants_color:
    $pants.modulate = pants_color
  if $shoes.modulate != shoes_color:
    $shoes.modulate = shoes_color
  if $hair.modulate != hair_color:
    $hair.modulate = hair_color
  
  for c in get_children():
    if not c is AnimatedSprite2D:
      return
    var anim_key = animation
    match(c.name):
      "body":
        pass
      "hair":
        anim_key = str(hair_style, "_", animation)
      "eyes":
        if anim_key == "up":
          pass
        else:
          anim_key = str(eye_style, "_", animation)
      "sclera":
        pass
      "pants":
        anim_key = str(pants_style, "_", animation)
      "shirt":
        anim_key = str(shirt_style, "_", animation)
      "shoes":
        anim_key = str(shoe_style, "_", animation)
      _:
        print(c.name)
    if c.animation != anim_key:
      c.animation = anim_key
    if not playing and c.frame != frame:
      c.frame = frame
    if playing and not c.is_playing():
      c.play()
    elif not playing and c.is_playing():
      c.stop()

func play(anim):
  animation = anim
  playing = true

func serialize():
  return {
    'eye_color': eye_color,
    'skin_color': skin_color,
    'shirt_color': shirt_color,
    'pants_color': pants_color,
    'shoes_color': shoes_color,
    'hair_color': hair_color,
  }
  
func deserialize(obj):
  eye_color = obj['eye_color']
  skin_color = obj['skin_color']
  shirt_color = obj['shirt_color']
  pants_color = obj['pants_color']
  shoes_color = obj['shoes_color']
  hair_color = obj['hair_color']
