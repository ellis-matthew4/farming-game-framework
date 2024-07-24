extends CanvasLayer

@onready var charNodes = get_node("Characters")
@onready var textBox = get_node("TextBox/TextControl/Dialogue")
@onready var nameBox = get_node("TextBox/TextControl/Name")
var choice = preload("res://xdl/Choice.tscn") # Change this!

var labels = {}
var variables = {}
var stack = []
var active = true
var skip = false
var auto = false
var working = false
var able = true
var rendering_line = false
var rendering_index = 1

var tempSave = null

var line
var TEXT_SPEED = 10
var AUTO_SPEED = 2

var path_to_folder = "res://xdl/output/" # Change this!
var currentScript
var currentScene

var npc_cache = []

signal done
signal lineFinished

enum {operator, operand, leftparentheses, rightparentheses, empty}

func serialize():
  var save = {}
  save["chars"] = getCharacterStates()
  save["vars"] = variables
  save["line"] = line
  save["stack"] = stack
  save["script"] = currentScript
  save["scene"] = currentScene
  return var_to_str(save)
  
func deserialize(save):
  save = str_to_var(save)
  read(save["script"])
  variables = save["vars"]
  line = save["line"]
  stack = save["stack"]
  loadScene(save["scene"])
  for c in save["chars"]:
    var t = save["chars"][c]
    get_node(c).visible = t["visible"]
    get_node(c).global_position = t["position"]
    get_node(c).play(t["emote"])
  statement()
  
func getCharacterStates():
  var d = {}
  for c in $Characters.get_children():
    var temp = {}
    temp["visible"] = c.visible
    temp["position"] = c.global_position
    temp["emote"] = c.animation
    d[get_path_to(c)] = temp
  return d

func _ready():
  read("sample.json")
  
func _physics_process(delta):
  if active:
    if len(stack) > 0: #Triggers upon calling or jumping
      if len(stack[0]) == 0:
        stack.pop_front()
      if Input.is_action_just_pressed("player_interact"):
        nextLine()
      elif skip:
        if len(stack) > 0:
          if stack.front().front()["action"] != "menu":
            nextLine()
        else:
          end()
    elif Input.is_action_just_pressed("player_interact") and working:
      end()
      # get_tree().call_group("playable_characters", "showGUI") #My games' command to show the HUD
  if Input.is_key_pressed(KEY_CTRL):
    skip = true
  else:
    skip = false
    
func unload():
  labels = {}
  
func read(filename):
  var file = FileAccess.open(path_to_folder + filename, FileAccess.READ)
  var data = file.get_as_text()
  file.close()
  var json = JSON.new()
  var error = json.parse(data)
  if error != OK:
    print("FAILED TO READ FILE " + filename)
    return
  data = json.data
  labels = data["labels"]
  currentScript = filename

func nextLine():
  if rendering_line:
    rendering_index = len(line["String"])
  else:
    if stack[0]["index"] >= len(labels[stack[0]["label"]]):
      stack.pop_front()
    if len(stack) == 0:
      end()
      return
    var cLabel = labels[stack[0]["label"]]
    line = cLabel[stack[0]["index"]]
    stack[0]["index"] += 1
    statement()

func statement():
  if $Centered.text != "":
    $Centered.text = ""
  match line["action"]:
    "show":
      Show()
    "hide":
      Hide()
    "dialogue":
      dialogue()
    "adialogue":
      adialogue()
    "centered":
      line["String"] = line["String"].format(variables)
      centered(1)
    "scene":
      Scene()
    "call":
      _call(line["label"])
    "jump":
      jump(line["label"])
    "var":
      variable()
    "menu":
      menu()
    "window":
      window()
    "play":
      play()
    "if":
      condition()
    "show_npc":
      show_npc()
    "hide_player":
      hide_player()
    "hide_all_npcs":
      hide_all_npcs()
    "cleanup_after_event":
      cleanup_after_event()
    _:
      print(line)
      nextLine()
      
func show_npc():
  var args = line['args']
  var n = Globals.find_npc(args[0])
  if args[0] == 'player':
    print('moving player')
    n = Globals.player()
  else:
    n.event_mode = true
  n.show()
  if args[4] == 'teleport':
    n.travel_stack.append(Vector3(int(args[1]),int(args[2]),1))
  elif args[4] == 'walk':
    n.travel_stack.append(Vector3(int(args[1]),int(args[2]),0))
  var dir = _direction(args[3])
  n.travel_stack.append(Vector3(dir.x, dir.y, 2))
  print('waiting for ', args[0])
  await n.finished
  print('done waiting for ', args[0])
  nextLine()
  
func hide_player():
  var p = Globals.player()
  p.hide()
  nextLine()
  
func _direction(string):
  match(string):
    'left': return Vector2.LEFT
    'up': return Vector2.UP
    'down': return Vector2.DOWN
    'right': return Vector2.RIGHT
  
func hide_all_npcs():
  get_tree().call_group('NPC', 'hide')
  nextLine()
  
func cleanup_after_event():
  get_tree().call_group('NPC', 'show')
  get_tree().call_group('NPC', 'teleport_based_on_schedule')
  get_tree().call_group('NPC', 'set_event_mode', false)
  var p = Globals.player()
  p.show()
  Globals.movement_blocked = false
  nextLine()
  
func _call(label):
  if able:
    working = true
    push(label)
    $TextBox.visible = true
    nextLine()
  
func jump(label):
  if able:
    working = true
    stack = [ { "label": label, "index": 0 } ]
    nextLine()
  
func push(label):
  stack.push_front( { "label": label, "index": 0 } )
  
func Show(): # Show statement
  var c = charNodes.get_node(line["char"])
  c.global_position = $Positions.get_node(line["pos"]).global_position
  c.play(line["emote"])
  c.visible = true
  nextLine()
  
func Hide(): # Hide statement
  var c = charNodes.get_node(line["char"])
  c.global_position = Vector2(0,0)
  c.visible = false
  nextLine()
func hideAll(): # Hides SukiGD
  get_node("TextBox").visible = false
  textBox.text = ""
  nameBox.text = ""
  for c in charNodes.get_children():
    c.global_position = Vector2(0,0)
    c.visible = false
  for sc in $Scenes.get_children():
    sc.visible = false
    
func dialogue(): # Displays a line of dialogue
  if line.has("emote"):
    var c = charNodes.get_node(line["char"])
    c.play(line["emote"])
  $TextBox/Namebox.visible = true
  nameBox.visible = true
  nameBox.text = line["char"].capitalize()
  line["String"] = line["String"].format(variables)
  rendering_index = 1
  rollingDisplay()

func adialogue():
  $TextBox/Namebox.visible = false
  nameBox.visible = false
  line["String"] = line["String"].format(variables)
  rendering_index = 1
  rollingDisplay()
  
func centered(index):
  if line["action"] == "centered":
    if index <= len(line["String"]):
      $Centered.text = line["String"].substr(0,index)
      await get_tree().create_timer(pow(10,-TEXT_SPEED)).timeout
      centered(index + 1)
    else:
      emit_signal("lineFinished")
  
func rollingDisplay():
  if line == {}:
    return
  if line["action"] in ["dialogue", "adialogue"]:
    if rendering_index <= len(line["String"]):
      rendering_line = true
      textBox.text = line["String"].substr(0,rendering_index)
      await get_tree().create_timer(pow(10,-TEXT_SPEED)).timeout
      rendering_index += 1
      rollingDisplay()
    else:
      rendering_line = false
      textBox.text = line["String"]
      emit_signal("lineFinished")
  
func Scene(): # Changes the backdrop to the current scene
  for sc in $Scenes.get_children():
    sc.visible = false
  get_node("Scenes/" + line["scene"]).visible = true
  currentScene = line["scene"]
  nextLine()
func loadScene(s): # Changes the backdrop to a given string
  for sc in $Scenes.get_children():
    sc.visible = false
  get_node("Scenes/" + s).visible = true
  currentScene = s
    
func end():
  line = {}
  hideAll()
  working = false
  emit_signal("done")
  able = false
  await get_tree().create_timer(0.5).timeout
  able = true
  
func variable():
  variables[line["name"]] = line["value"]
  nextLine()
  
func _access_internal_variable(variable):
  return variables[variable]
  
func option(o):
  var c = choice.instantiate()
  $Menu.add_child(c)
  c.text = o["string"]
  c.connect("interact",Callable(self,"menu_interact").bind(o))
  
func menu():
  $Menu.visible = true
  $TextBox.visible = false
  active = false
  for o in line["options"]:
    option(o)
  
func menu_interact(o):
  if o["protocol"] == "call":
    _call(o["target"])
  else:
    jump(o["target"])
  $Menu.visible = false
  $TextBox.visible = true
  active = true
  for c in $Menu.get_children():
    c.queue_free()
  nextLine()
  
func window():
  var tb = get_node("TextBox")
  if line["value"] == "hide":
    tb.visible = false
  else:
    tb.visible = true
  nextLine()
     
func play():
  $AnimationPlayer.play(line["anim"])
  await $AnimationPlayer.animation_finished
  print("Finished ", line["anim"])
  nextLine()
  
func condition():
  var result
  var op1 = expression(line["op1"])
  var op2 = expression(line["op2"])
  match(line["opr"]):
    "==": result = op1 == op2
    "!=": result = op1 <= op2
    ">=": result = op1 >= op2
    "!=": result = op1 != op2
    ">": result = op1 > op2
    "<": result = op1 < op2
    _: print("ERROR! BAD OPERAND")
  if result:
    match(line["protocol"]):
      "call": _call(line["target"])
      "jump": jump(line["target"])
      _: print("INVALID PROTOCOL")
    
func _on_root_lineFinished():
  if auto:
    await get_tree().create_timer(AUTO_SPEED).timeout
    nextLine()

func expression(pf):
  for i in range(len(pf)):
    if variables.has(pf[i]):
      pf[i] = variables[pf[i]]
  var local_stack = []
  while len(pf) > 0:
    var c = pf.pop_front()
    if TypeOf(c) == operator:
      var a = float(local_stack.pop_front())
      var b = float(local_stack.pop_front())
      var r
      match(c):
        "+": r = a + b
        "-": r = a - b
        "*": r = a * b
        "/": r = a / b
      local_stack.push_front(r)
    else:
      local_stack.insert(0,c)
  return str(local_stack[0])

func TypeOf(s):
  s = str(s)
  if s == '(':
    return leftparentheses
  elif s == ')':
    return rightparentheses
  elif s == '+' or s == '-' or s == '*' or s == '%' or s == '/':
    return operator
  elif s == ' ':
    return empty    
  else :
    return operand  
