extends CenterContainer

var control = "":
  set(value):
    control = value
    $VBoxContainer/Label.text = value
var options = []:
  set(value):
    options = value
    $VBoxContainer/HBoxContainer/Panel/MarginContainer/Label.text = _render_text(options[selected])
var selected = 0:
  set(value):
    selected = value
    $VBoxContainer/HBoxContainer/Panel/MarginContainer/Label.text = _render_text(options[selected])
    emit_signal("changed", selected_value(), selectedColor)
    
var selectedColor = Color.BLACK:
  set(value):
    selectedColor = value
    $VBoxContainer/HBoxContainer/ColorPickerButton.color = value
    emit_signal("changed", selected_value(), selectedColor)

signal changed(value, color)
    
func _render_text(text: String):
  return text.capitalize()
    
func selected_value():
  return options[selected]
    
func _on_l_button_pressed():
  if options.size() == 0:
    return
  if selected == 0:
    selected = options.size() - 1
  else:
    selected -= 1

func _on_r_button_pressed():
  if options.size() == 0:
    return
  if selected == options.size() - 1:
    selected = 0
  else:
    selected += 1

func _on_color_picker_button_color_changed(color):
  selectedColor = color

func hide_color_picker():
  $VBoxContainer/HBoxContainer/ColorPickerButton.hide()
