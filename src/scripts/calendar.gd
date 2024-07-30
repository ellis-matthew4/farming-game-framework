extends Control

var year: int = 1
var season: int = 0
var day: int = 0
var dow: int = 0

var days_of_week = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
var seasons = ['Spring', 'Summer', 'Fall', 'Winter']
    
func _ready():
  Globals.calendar = self
  parse_day(Globals.day)
  
func get_date_string():
  return days_of_week[dow] + ", " + seasons[season] + ' ' + str(day)

func parse_day(d):
  d = int(d)
  dow = d % 7
  year = d / (31*4) + 1
  d = d % (31*4)
  season = d / 31
  day = d % 31 + 1
  $ColorRect/Label.text = get_date_string()
