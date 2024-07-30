extends Button

signal pressed2(btn)

func _ready():
  self.connect('pressed', _on_pressed)

func _on_pressed():
  emit_signal("pressed2", self)
