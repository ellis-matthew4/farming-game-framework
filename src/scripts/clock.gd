extends Control

class_name Clock

var time = 360
var increment = 1

enum { MORNING, DAY, EVENING, NIGHT }

signal day_change

func _ready():
  Globals.clock = self
  _increment_time()
  await get_tree().create_timer(0.01).timeout
  Globals.menuLayer.transition("morning")

func _increment_time():
  await get_tree().create_timer(increment).timeout
  if not Globals.time_stopped:
    time = time + 1 if time < 1440 else 0
    var hour = _format(time / 60)
    var minute = _format(time % 60)
    $ColorRect/Label.text = hour + ":" + minute
    if time == 359:
      Globals.menuLayer.transition("night_to_morning")
    elif time == 719:
      Globals.menuLayer.transition("morning_to_day")
    elif time == 1019:
      Globals.menuLayer.transition("day_to_evening")
    elif time == 1199:
      Globals.menuLayer.transition("evening_to_night")
    elif time == 360:
      emit_signal("day_change")
    elif time == 0:
      Globals.increment_day()
  _increment_time()

func _format(num):
  num = str(num)
  if len(num) == 1:
    num = "0" + num
  return num

func get_time_group():
  if time < 360:
    return NIGHT
  elif time >= 360 and time < 720:
    return MORNING
  elif time >= 720 and time < 1020:
    return DAY
  elif time >= 1080 and time < 1200:
    return EVENING
  else:
    return NIGHT
