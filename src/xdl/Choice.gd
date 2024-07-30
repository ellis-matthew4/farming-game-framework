extends TextureButton

var text:
  set(value):
    text = value
    $Label.text = value

signal interact

func _on_Choice_pressed():
  emit_signal("interact")
