extends Control

var SkinColorChoice
var HairChoice
var EyeChoice
var ShirtChoice
var PantsChoice
var ShoeChoice
var SexChoice
var CharName
var CharacterSprite

@export_enum ("BASIC", "EDIT", "ADMIN") var mode = "BASIC"
signal done

var rotation_index = 0:
  set(value):
    if value == 4:
      rotation_index = 0
    elif value == -1:
      rotation_index = 3
    else:
      rotation_index = value
    if rotation_index == 0:
      CharacterSprite.flip_h = false
      CharacterSprite.animation = "down"
    elif rotation_index == 1:
      CharacterSprite.flip_h = true
      CharacterSprite.animation = "side"
    elif rotation_index == 2:
      CharacterSprite.flip_h = false
      CharacterSprite.animation = "up"
    elif rotation_index == 3:
      CharacterSprite.flip_h = false
      CharacterSprite.animation = "side"
    

func _ready():
  CharacterSprite = find_child("CharacterSprite")
  
  SkinColorChoice = find_child("SkinColorChoice")
  SkinColorChoice.color = CharacterSprite.skin_color
  
  HairChoice = find_child("HairChoice")
  HairChoice.options = CharacterSprite.exposed_hair_styles
  HairChoice.selectedColor = CharacterSprite.hair_color
  HairChoice.control = "Hairstyle: "
  
  EyeChoice = find_child("EyeChoice")
  EyeChoice.options = CharacterSprite.exposed_eye_styles
  EyeChoice.selectedColor = CharacterSprite.eye_color
  EyeChoice.control = "Eye Style: "
  
  ShirtChoice = find_child("ShirtChoice")
  ShirtChoice.options = CharacterSprite.exposed_shirt_styles
  ShirtChoice.selectedColor = CharacterSprite.shirt_color
  ShirtChoice.control = "Shirt Style: "
  
  PantsChoice = find_child("PantsChoice")
  PantsChoice.options = CharacterSprite.exposed_pants_styles
  PantsChoice.selectedColor = CharacterSprite.pants_color
  PantsChoice.control = "Pants Style: "
  
  ShoeChoice = find_child("ShoeChoice")
  ShoeChoice.options = CharacterSprite.exposed_shoe_styles
  ShoeChoice.selectedColor = CharacterSprite.shoes_color
  ShoeChoice.control = "Shoe Style: "
  
  SexChoice = find_child("SexChoice")
  SexChoice.options = ["male", "female"]
  SexChoice.control = "Sex: "
  SexChoice.hide_color_picker()
  
  CharName = find_child("CharName")

func _on_hair_choice_changed(new, color):
  CharacterSprite.hair_style = new
  CharacterSprite.hair_color = color

func _on_eye_choice_changed(new, color):
  CharacterSprite.eye_style = new
  CharacterSprite.eye_color = color

func _on_shirt_choice_changed(new, color):
  CharacterSprite.shirt_style = new
  CharacterSprite.shirt_color = color

func _on_pants_choice_changed(new, color):
  CharacterSprite.pants_style = new
  CharacterSprite.pants_color = color

func _on_shoe_choice_changed(new, color):
  CharacterSprite.shoe_style = new
  CharacterSprite.shoes_color = color

func _on_rotate_l_btn_pressed():
  rotation_index -= 1

func _on_rotate_r_btn_pressed():
  rotation_index += 1

func _on_walk_cycle_toggle_toggled(toggled_on):
  CharacterSprite.playing = toggled_on
  CharacterSprite.frame = 0

func _on_skin_color_choice_color_changed(color):
  CharacterSprite.skin_color = color

func _on_finish_btn_pressed():
  match(mode):
    "BASIC":
      Globals.player_char = CharacterSprite.serialize()
    "EDIT":
      Globals.player_char = CharacterSprite.serialize()
      Globals.player().find_child("AnimatedSprite2D").deserialize(Globals.player_char)
    "ADMIN":
      $FileDialog.popup_centered_ratio()
  emit_signal("done")

func _on_file_dialog_file_selected(path):
  if not mode == "ADMIN":
    return
  var json = JSON.stringify(CharacterSprite.serialize())
  var f = FileAccess.open(path, FileAccess.WRITE)
  f.store_string(json)
  f.close()
  await get_tree().create_timer(0.01).timeout
