extends Control

@onready var emitBtnScn = preload("res://scenes/Menus/emit_button.tscn")

func _ready():
  $Main.show()
  $Saves.hide()
  _generate_saves()

func _on_new_pressed():
  $Main.hide()
  $CharEdit.show()

func _on_load_pressed():
  $Main.hide()
  $Saves.show()

func _back(_btn):
  $Main.show()
  $Saves.hide()
  
func _load_game(btn):
  Globals.start_game(btn.text)

func _on_options_pressed():
  pass # Replace with function body.

func _on_quit_pressed():
  get_tree().quit()

func _generate_saves():
  var saves = Globals.get_save_files()
  for s in saves:
    var btn = emitBtnScn.instantiate()
    btn.text = s
    $Saves.add_child(btn)
    btn.connect("pressed2", _load_game)
  var back_btn = emitBtnScn.instantiate()
  back_btn.text = "Back"
  $Saves.add_child(back_btn)
  back_btn.connect("pressed2", _back)

func _on_character_editor_done():
  Globals.start_game(null)
