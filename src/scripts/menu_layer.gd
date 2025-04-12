extends CanvasLayer

var ingame_menu = preload("res://scenes/Menus/ingame_menu.tscn")
var quick_inv = preload("res://scenes/Menus/quick_inventory.tscn")
var pauseMenu = preload("res://scenes/Menus/pause_menu.tscn")
var debug = preload("res://scenes/Menus/debug.tscn")
var time_display = preload("res://scenes/Menus/time_display.tscn")
var debugging = false
var reset_timer = false
var time_display_inst

signal xdl_done
signal fadein
signal fadeout

func _ready():
  time_display_inst = time_display.instantiate()
  add_child(time_display_inst)
  #$AnimationPlayer/DayNightCycle.show()

func debug_menu():
  if not reset_timer:
    if debugging:
      debugging = false
      get_node("Debug").queue_free()
    else:
      debugging = true
      add_child(debug.instantiate())
      reset(0.125)
      
func set_weather():
  hide_weather()
  var w = Globals.weather
  if w == 'rain':
    $AnimationPlayer/RainEffect.visible = true
  if w == 'snow':
    $AnimationPlayer/SnowEffect.visible = true
    
func hide_weather():
  $AnimationPlayer/RainEffect.visible = false
  $AnimationPlayer/SnowEffect.visible = false

func ig_menu():
  menu_show(ingame_menu.instantiate())
  
func pause_menu():
  menu_show(pauseMenu.instantiate())

func menu_show(menu):
  Globals.movement_blocked = true
  $quick_inventory.hide()
  add_child(menu)
  
func menu_hide(menu):
  Globals.movement_blocked = false
  $quick_inventory.show()
  menu.queue_free()

func reset(timeout):
  reset_timer = true
  await get_tree().create_timer(timeout).timeout
  reset_timer = false

func transition(ts):
  Globals.transitioning = true
  $AnimationPlayer.play(ts)
  if ts == "fade_out":
    $quick_inventory.hide()
    await $AnimationPlayer.animation_finished
    emit_signal("fadeout")
  if ts == "fade_in":
    await $AnimationPlayer.animation_finished
    $quick_inventory.show()
    emit_signal("fadein")
    Globals.transitioning = false
    
func hide_hud():
  $quick_inventory.hide()
  time_display_inst.hide()
  
func show_hud():
  $quick_inventory.show()
  time_display_inst.show()

func xdl_call(label):
  time_display_inst.hide()
  $quick_inventory.hide()
  $xdl.show()
  $xdl._call(label)
  await $xdl.done
  print("XDL Finished ", label)
  $quick_inventory.show()
  time_display_inst.show()
  $xdl.hide()
  emit_signal("xdl_done")

func xdl_able():
  return $xdl.able

func open_shop(context):
  $Shop.depopulate()
  if $Shop.working:
    await $Shop.empty
  $Shop.populate(context)
  if $Shop.working:
    await $Shop.populated
  hide_hud()
  $Shop.show()

func close_shop():
  $Shop.hide()
  show_hud()
  $Shop.depopulate()

func open_cedit(mode):
  hide_hud()
  $CE_Container/CharacterEditor.mode = mode
  $CE_Container.show()
  
func hide_cedit():
  show_hud()
  $CE_Container.hide()

func _on_character_editor_done():
  hide_cedit()
