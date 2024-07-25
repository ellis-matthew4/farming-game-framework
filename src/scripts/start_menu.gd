extends Control

func _on_new_pressed():
  Globals.start_game(null)

func _on_load_pressed():
  Globals.start_game('test')

func _on_options_pressed():
  pass # Replace with function body.

func _on_quit_pressed():
  get_tree().quit()
