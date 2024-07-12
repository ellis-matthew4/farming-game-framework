extends Node

class_name AffectionManager

# This object holds the affection of all NPCs and animals in the game
var db = {
  "npc": 0
}

var keys = ['worst', 'hated', 'disliked', 'loved', 'best']
var gifts = {
  "npc": {
    "worst": ['generic_seeds'],
    "hated": [],
    "disliked": [],
    "loved": ['generic_crop'],
    "best": [],
  }
}

var days_since_interact = {
  "npc": 0
}

var increment = 6553

func increment_day():
  for n in days_since_interact.keys():
    days_since_interact[n] += 1
    if days_since_interact[n] >= 7:
      change_affection(n, -100, false, false)

func get_affection_level(id):
  var points = db[id]
  return points / increment
  
func gift_level(npc_id, item_id):
  for key in keys:
    if item_id in gifts[npc_id][key]:
      return key
  return 'liked'
  
func gift_affection(npc: NPC, item_id):
  var amount
  var level = gift_level(npc.npc_name, item_id)
  match(level):
    'worst':
      amount = -1000
    'hated':
      amount = -500
    'disliked':
      amount = -200
    'liked':
      amount = 150
    'loved':
      amount = 500
    'best':
      amount = 800
  change_affection_for(npc, amount)
  return level
  
func talk_affection(npc: NPC):
  var id = npc.npc_name
  if days_since_interact[id] > 0:
    change_affection_for(npc, 100)
    days_since_interact[id] = 0

func change_affection_for(npc: NPC, amount):
  change_affection(npc.npc_name, amount, npc.is_birthday(), npc.spouse)

func change_affection(npc_id, amount, is_birthday, is_spouse):
  if amount < 0:
    db[npc_id] = max(0, db[npc_id] + amount) # plus a negative
  else:
    var maximum = increment * (20 if is_spouse else 10)
    if is_birthday:
      amount *= 2
    db[npc_id] = min(amount, maximum)

func serialize():
  return {
    'db': db,
    'gifts': gifts,
    'days_since_interact': days_since_interact
  }
