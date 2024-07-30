extends Control

func _ready():
  _refresh()

func _process_text(h):
  var result = "fps: " + str(Engine.get_frames_per_second()) + "\n"
  for key in h.keys():
    result += key + ": " + str(h[key]) + "\n"
  return result

func _refresh():
  $Label.text = _process_text(Globals.get_state())
  await get_tree().create_timer(1).timeout
  _refresh()
