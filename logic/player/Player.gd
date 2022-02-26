extends Node2D

#signal step
signal step
signal done_movement
signal wild_battle
signal trainer_battle(npc_trainer)

enum State {
	IDLE,
	MOVE,
	FISH
}
 
enum MovementType {
	FOOT,
	BIKE,
	SURF,
	SCUBA
}
	   
enum MovementSpeed {
	NORMAL,
	FAST
}

enum Direction{
	DOWN,
	LEFT,
	RIGHT,
	UP,
	DOWN_LEFT,
	UP_RIGHT
}

export var can_move = true

var walk_texture = null
var run_texture = null

var is_moving = false
var last_facing_dir
var is_input_disabled = false
var foot = 0

var did_bump = false

var check_x = 0
var check_y = 0
var check_pos = Vector2()

var is_holding_z = false

var move_direction = Vector2()
var stair_offset = Vector2.ZERO

var action
var direction
var movement_type = MovementType.FOOT
var movement_speed
var state

var did_find_grass = false
var did_enter_grass = false
var did_exit_grass = false

var is_blocked = false
var do_jump = false


func _ready() -> void:
	self.add_to_group("auto_z_layering")
	load_texture()
 
func _process(delta) -> void:
	# If the hero is not moving
	if !is_moving:
		# If the hero can move and is not pressing accept, then get input
		if can_move and !Input.is_action_pressed("ui_accept") and !is_moving:
			get_input()
		# If the hero can move and presses accept, then call the interact method
		elif can_move and Input.is_action_just_pressed("ui_accept"):
			interact()
			pass

func change_input(lock = false) -> void: # Disables/Enables the player to interaction and now movement
	if lock:
		$Collision/Area2D/CollisionShape2D.disabled = true
		is_input_disabled = true
		can_move = false
	else:
		$Collision/Area2D/CollisionShape2D.disabled = false
		is_input_disabled = false
		can_move = true
	set_idle_frame(direction)

func get_input() -> void:
	if Input.is_action_pressed("ui_down"):
		direction = Direction.DOWN
	elif Input.is_action_pressed("ui_up"):
		direction = Direction.UP
	elif Input.is_action_pressed("ui_left"):
		direction = Direction.LEFT
	elif Input.is_action_pressed("ui_right"):
		direction = Direction.RIGHT
	elif Input.is_action_pressed("ui_debug"):
		Global.debug = true
	else:
		Global.debug = false
		return
		
	#if the player presses z and is not holding z and can run, then set is_holding_z to be true and global sprint to false
	if Input.is_action_pressed("z") and !is_holding_z and Global.can_run:
		is_holding_z = true
		Global.sprint = !Global.sprint
	#If the above is false and z is not pressed and is_holding_z is true, then is_holding_z is flase and global sprint is set to flase
	elif !Input.is_action_pressed("z") and is_holding_z:
		is_holding_z = false
		Global.sprint = !Global.sprint
	
	state = State.MOVE
	
	#If the state equals State.MOVE, the player is on foot and global sprint is on, then movement speed is set to fast and the texture is set to run
	if state == State.MOVE and movement_type == MovementType.FOOT and Global.sprint == true:
		movement_speed = MovementSpeed.FAST
		$Position2D/Sprite.texture = run_texture
	#If the above is false, then movemnet speed is set to normal and the walk texture is used
	else:
		movement_speed = MovementSpeed.NORMAL
		$Position2D/Sprite.texture = walk_texture


	# Check if door is ahead
#	var ahead
#	match direction:
#		Direction.UP:
#			ahead = get_position_relative_to_current_scene() + Vector2(0, -32)
#		Direction.DOWN:
#			ahead = get_position_relative_to_current_scene() + Vector2(0, 32)
#		Direction.LEFT:
#			ahead = get_position_relative_to_current_scene() + Vector2(-32, 0)
#		Direction.RIGHT:
#			ahead = get_position_relative_to_current_scene() + Vector2(32, 0)
#	var is_door_ahead = false
	#print(ahead)

#	for door in Global.game.doors:
#		var door_pos = door.position
#
#		if door_pos == ahead:
#			is_door_ahead = true
#			print("door is ahead")
#			door.transition()
#			return
#
#	# Check if cliff is ahead
#	var the_cliff = null
#	for cliff in Global.game.cliffs:
#		var cliff_positions = cliff.get_cliff_positions()
#		if cliff_positions.has(ahead):
#			the_cliff = cliff
#			break
#	do_jump = false
#	is_blocked = false
#	if the_cliff != null:
#		match direction:
#			Direction.UP:
#				if the_cliff.jump_direction == "Up":
#					do_jump = true
#			Direction.DOWN:
#				if the_cliff.jump_direction == "Down":
#					do_jump = true
#			Direction.LEFT:
#				if the_cliff.jump_direction == "Left":
#					do_jump = true
#			Direction.RIGHT:
#				if the_cliff.jump_direction == "Right":
#					do_jump = true
#
#		if do_jump:
#			jump()
#			return
#		else:
#			is_blocked = true

	#If input is disabled then you cannot move
	if !is_input_disabled:
		move(false)

func check_grass(dir) -> void:
	for grass in get_tree().get_nodes_in_group("grass"):
		for collision in $NextCollision.get_children():
			#print(grass.world_to_map(collision.global_position))
			for g in grass.get_used_cells_by_id(0):
				if collision.name == "Right":
					pass
				#print(str(collision.name, collision.global_position, "\n", grass.map_to_world(grass.get_used_cells_by_id(0)[0]) + Vector2(2208 + 64, 864) - Vector2(16, 16)))

				var tile_center_pos = grass.map_to_world(g) + grass.cell_size / 2
				#print(g + Vector2(2208, 864))
				if grass.map_to_world(g) == collision.global_position:
					if !Global.grassPos.has(collision.name):
						Global.grassPos.append(collision.name)
					did_find_grass = true
					break
					#Global.grassPos.remove(Global.grassPos.find(collision.name))
				else:
					if Global.grassPos.has(collision.name):
						#print(collision.name)
						Global.grassPos.remove(Global.grassPos.find(collision.name))
			#if did_find_grass:
			#	return
		did_find_grass = false
	pass

func interact() -> void:
	var check = self.position
	match direction:
		Direction.DOWN:
			check += Vector2(0, 32)
		Direction.UP:
			check += Vector2(0, -32)
		Direction.LEFT:
			check += Vector2(-32, 0)
		Direction.RIGHT:
			check += Vector2(32, 0)
	print("Player.gd" + str(check))
	#Get the parent node and check the position and direction
	Global.game.interaction(check, direction)

func move(force_move : bool) -> void:
	set_process(false)
	is_moving = true
	move_direction = Vector2.ZERO

	var was_indoors = false
#	if "type" in Global.game.current_scene && !Global.game.current_scene.type == "Outside":
#		was_indoors = true
	
	if direction == Direction.DOWN and ($NextCollision/Down.get_overlapping_bodies().size() == 0 or force_move or Global.debug):
			move_direction.y = 32
	if direction == Direction.UP and ($NextCollision/Up.get_overlapping_bodies().size() == 0 or force_move or Global.debug):
			move_direction.y = -32
	if direction == Direction.LEFT and ($NextCollision/Left.get_overlapping_bodies().size() == 0 or force_move or Global.debug):
			move_direction.x = -32
	if direction == Direction.RIGHT and ($NextCollision/Right.get_overlapping_bodies().size() == 0 or force_move or Global.debug):
			move_direction.x = 32
	if direction == Direction.DOWN_LEFT:
		move_direction.x = -32
		move_direction.y = 32
	if direction == Direction.UP_RIGHT:
		move_direction.x = 32
		move_direction.y = -32
	last_facing_dir = direction

	if is_blocked:
		move_direction = Vector2.ZERO

	# Grass logic
	var grass1 = $Grass/Sprite # Current grass under player
	var grass2 = $Grass/Sprite2 # Grass player is moving to
	var grass_tween = $GrassTween
	var grass_found = false
	did_enter_grass = false
	did_exit_grass = false
	
#	if move_direction != Vector2.ZERO:
#		TerrainTags.get_tile_terrain_tag(self.position + move_direction)
#
	if Global.onStairsUp:
#		if move_direction.x > 0:
#			stair_offset = Vector2(0, 32)
#		elif move_direction.x > 0:
#			stair_offset = Vector2(0, 16)
		Global.wasOnStairs = true
	elif Global.wasOnStairs and !Global.onStairsUp:
		if move_direction.x < 0:
			stair_offset = Vector2(0, -32)
		if move_direction.x > 0:
			stair_offset = Vector2(0, 32)
		Global.wasOnStairs = false
	else:
		stair_offset = Vector2.ZERO
	
	
	set_grass(direction)
	
	# Start Animation
	animate()
	
	# Set Tween settings
	if movement_speed == MovementSpeed.FAST:
		$Tween.interpolate_property(self, "position", self.position, self.position + move_direction + stair_offset, 0.125, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	else:
		$Tween.interpolate_property(self, "position", self.position, self.position + move_direction + stair_offset, 0.25, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	
	
	
	# Play did_bump effect is player can't move
	if move_direction == Vector2.ZERO: #TODO: add delay 
		$AudioStreamPlayer2D.stream = load("res://Audio/SE/did_bump.WAV")
		$AudioStreamPlayer2D.play(0.0)
	
	# Start Tween
	if did_enter_grass || did_exit_grass || Global.onGrass:
		$GrassTween.start()
	$Tween.start()

	# Wait until player finish move
	yield($Tween, "tween_all_completed")
	
	if Global.onGrass:
		$Grass.show()
		if !Global.grass_positions.has( self.position + Vector2(32, 0) ):
			$Grass/Sprite2.hide()
		$Grass/Sprite.show()
	else:
		$Grass.hide()
	

	$Grass.position = Vector2.ZERO
	
	if foot == 0:
		foot = 1
	else:
		foot = 0

	# Generate wild battle if on grass or if the scene calls for it.
#	var wild_gen_on_step = false
#	if "always_wild_gen_on_step" in Global.game.current_scene && Global.game.current_scene.always_wild_gen_on_step:
#		wild_gen_on_step = true
#
#	if (Global.onGrass || wild_gen_on_step) && !Global.block_wild && move_direction != Vector2.ZERO:
#		wild_poke_encounter()

	set_process(true)
	is_moving = false
	set_idle_frame()
	# trainer_encounter()
	
	emit_signal("step")

	# Check if player entered into a different scene. For outdoors only
#	if !force_move && "type" in Global.game.current_scene && Global.game.current_scene.type == "Outside" && !was_indoors:
#		var loc = Global.game.get_current_scene_where_player_is()
#		if Global.game.current_scene != loc:
#			if loc == null:
#				print("PLAYER ERROR: Got Null on current_scene.")
#			print("Player seamlessly entering different scene -> " + str(loc))
#			Global.game.change_scene(null)

#Loads the texture of the sprites you picked for your character
func load_texture() -> void:
	if Global.TrainerGender == 0:
		walk_texture = preload("res://assets/graphics/characters/hero.png")
		run_texture = preload("res://assets/graphics/characters/hero_run.png")
	if Global.TrainerGender == 1:
		walk_texture = preload("res://assets/graphics/characters/heroine.png")
		run_texture = preload("res://assets/graphics/characters/heroine_run.png")
	$Position2D/Sprite.texture = walk_texture
	$Position2D/Sprite.frame = 0

#Sets the sprite texture to the walk_texture and if the direction is not null then the sprite.frame is set to direction times 4
func set_idle_frame(_dir = null) -> void:
	state = State.IDLE
	$Position2D/Sprite.texture = walk_texture
	if _dir == null:
		_dir = last_facing_dir
	$Position2D/Sprite.frame = int(Direction.values()[_dir]) * 4


# Play the move animation
func animate() -> void:
	var _animation_name : String = Direction.keys()[direction].to_lower().capitalize()
	if Global.sprint:
		_animation_name += "_sprint"
	if foot == 1:
		_animation_name += "2"
	$AnimationPlayer.play(_animation_name)


#Sets the texture to the walk texture, and if the pacing direction isn't null then set the frame to be the facing_dir * 4
func set_facing_direction(facing_dir) -> void:
	direction = Direction.keys()[facing_dir]
	$Position2D/Sprite.texture = walk_texture
	$Position2D/Sprite.frame = direction * 4

func move_player_event(_dir, steps) -> void: # Force moves player to direction and steps
	direction = _dir
	steps = steps
	movement_speed = MovementSpeed.NORMAL
	for i in range(steps):
		move(true)
		yield(self, "step")
	emit_signal("done_movement")

func set_grass(dir) -> void:
	var speed := 0.125 if Global.sprint else 0.25
	if did_enter_grass:
		$Grass/Sprite.texture = load(Global.grassSprite)
		$Grass/Sprite2.texture = load(Global.grassSprite)
		#print("did_enter_grass")
		match dir:
			"Right", Direction.RIGHT:
				$Grass.show()
				$Grass/Sprite2.show()
				$Grass/Sprite.hide()
				$GrassTween.interpolate_property($Grass, "position", $Grass.position, $Grass.position - move_direction, speed, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
			"Left", Direction.LEFT:
				$Grass.show()
				$Grass/Sprite2.hide()
				$Grass/Sprite.show()
				$Grass.position = Vector2(-32, 0)
				$GrassTween.interpolate_property($Grass, "position", $Grass.position, $Grass.position - move_direction, speed, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
			"Up", Direction.UP:
				$GrassTween.interpolate_property($Grass/Sprite, "region_rect", Rect2(Vector2(32, 80), Vector2(32, 16)), Rect2(Vector2(32, 80 - 32), Vector2(32, 16)), speed, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
			"Down", Direction.DOWN:
				$Grass.show()
				$Grass/Sprite2.hide()
				$Grass/Sprite.show()
				$GrassTween.interpolate_property($Grass/Sprite, "region_rect", Rect2(Vector2(32, 80 - 32), Vector2(32, 16)), Rect2(Vector2(32, 80), Vector2(32, 16)), speed, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		return
	elif did_exit_grass:
		#print("did_exit_grass")
		match dir:
			"Right", Direction.RIGHT:
				$Grass.show()
				$Grass/Sprite.show()
				$Grass/Sprite2.hide()
				if !Global.sprint:
					$GrassTween.interpolate_property($Grass, "position", $Grass.position, $Grass.position - move_direction, 0.25, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
				else:
					$GrassTween.interpolate_property($Grass, "position", $Grass.position, $Grass.position - move_direction, 0.125, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
				
				return
				
				pass
			"Left", Direction.LEFT:
				$Grass.show()
				$Grass/Sprite2.show()
				$Grass/Sprite.hide()
				
				$Grass.position = Vector2(-32, 0)
				if !Global.sprint:
					$GrassTween.interpolate_property($Grass, "position", $Grass.position, $Grass.position - move_direction, 0.25, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
				else:
					$GrassTween.interpolate_property($Grass, "position", $Grass.position, $Grass.position - move_direction, 0.125, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
				
				return
				pass
			"Down", Direction.DOWN:
				$Grass.hide()
				return
			"Up", Direction.UP:
				$Grass.show()
				$Grass/Sprite.show()
				$Grass/Sprite2.hide()
				if !Global.sprint:
					$GrassTween.interpolate_property($Grass, "position", $Grass.position, $Grass.position + Vector2(0, 32), 0.25, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
				else:
					$GrassTween.interpolate_property($Grass, "position", $Grass.position, $Grass.position + Vector2(0, 16), 0.125, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
				
				return
		pass
	else:
		#print("else grass")
		if Global.onGrass:
			# change sprite texture
			if !Global.grass_positions.has(self.position + Vector2(32, 0)):
				print("TEST")
			
			
			$Grass.show()
			match dir:
				"Right", Direction.RIGHT:
					$Grass/Sprite.show()
					$Grass/Sprite2.show()
					print(Global.grass_positions)
					if Global.sprint:
						$GrassTween.interpolate_property($Grass, "position", $Grass.position, $Grass.position - move_direction, 0.125, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
					else:
						$GrassTween.interpolate_property($Grass, "position", $Grass.position, $Grass.position - move_direction, 0.25, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
					return
				"Left", Direction.LEFT:
					$Grass/Sprite.show()
					$Grass/Sprite2.show()
					$Grass.position = Vector2(-32, 0)
					if Global.sprint:
						$GrassTween.interpolate_property($Grass, "position", $Grass.position, $Grass.position - move_direction, 0.125, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
					else:
						$GrassTween.interpolate_property($Grass, "position", $Grass.position, $Grass.position - move_direction, 0.25, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
					return
				"Up", Direction.UP:
					$Grass/Sprite2.hide()
					if Global.sprint:
						$GrassTween.interpolate_property($Grass/Sprite, "region_rect", Rect2(Vector2(32, 80), Vector2(32, 16)), Rect2(Vector2(32, 80 - 32), Vector2(32, 16)), 0.125, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
					else:
						$GrassTween.interpolate_property($Grass/Sprite, "region_rect", Rect2(Vector2(32, 80), Vector2(32, 16)), Rect2(Vector2(32, 80 - 32), Vector2(32, 16)), 0.25, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
					return
				"Down", Direction.DOWN:
					$Grass/Sprite2.hide()
					if Global.sprint:
						$GrassTween.interpolate_property($Grass/Sprite, "region_rect", Rect2(Vector2(32, 80 - 32), Vector2(32, 16)), Rect2(Vector2(32, 80), Vector2(32, 16)), 0.125, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
					else:
						$GrassTween.interpolate_property($Grass/Sprite, "region_rect", Rect2(Vector2(32, 80 - 32), Vector2(32, 16)), Rect2(Vector2(32, 80), Vector2(32, 16)), 0.25, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
					return
		else:
			$Grass.hide()

func remove_grass(exiting) -> void:
	if Global.onGrass:
		match exiting:
			"Right", Direction.RIGHT:
				if direction == Direction.RIGHT:
					Global.onGrass = false
					Global.exitGrassPos = ""
					Global.grassPos = ""
					$Grass/Sprite2.hide()
					return
				else:
					Global.grassPos = ""
					Global.onGrass = true
			"Left", Direction.LEFT:
				if direction == Direction.LEFT:
					Global.exitGrassPos = ""
					Global.grassPos = ""
					Global.onGrass = false
					$Grass/Sprite.hide()
					$Grass/Sprite2.show()
					return
				else:
					Global.grassPos = ""
					Global.onGrass = true
				return

func wild_poke_encounter() -> void: # Info and formula based on : https://sha.wn.zone/p/pokemon-encounter-rate
	var trigger_wild_battle = false

	if did_enter_grass: # 40% chance to skip
		var num = Global.rng.randf()
		if num <= 0.4:
			# Skip
			return
	
	# Core Encounter Rate
	var rate : int = 20 # Base rate for external areas
	
	# Get custom rate if map specified
	if "base_encounter_rate" in Global.game.current_scene:
		rate = Global.game.current_scene.base_encounter_rate

	rate = rate * 16

	var modifier = 1.0
	
	# Apply modifers: TODO
	# Being on a bike 	80%
	# Having played the White Flute 	150%
	# Having played the Black Flute 	50%
	# Lead Pokémon has a Cleanse Tag 	66%
	# Lead Pokémon has the Stench ability (in Battle Pyramid) 	75%
	# Lead Pokémon has the Stench ability (everywhere else) 	50%
	# Lead Pokémon has the Illuminate ability 	200%
	# Lead Pokémon has the White Smoke ability 	50%
	# Lead Pokémon has the Arena Trap ability 	200%
	# Lead Pokémon has the Sand Veil ability in a sandstorm 	50%
	
	rate = int(rate * modifier)

	# Cap at 2880
	if rate > 2888:
		rate = 2880

	var value = Global.rng.randi() % 2880

	if rate > value:
		trigger_wild_battle = true
	
	if trigger_wild_battle:
		can_move = false
		set_idle_frame(direction)
		emit_signal("wild_battle")

func trainer_encounter() -> void:
	# Check if any trainers see the player
	if Global.game.trainers == null:
		return

	if !can_move: # Already in a battle.
		return

	for trainer in Global.game.trainers:
		if trainer != null && "seeking" in trainer && trainer.seeking:
			var check_positions = []
			var player_set_dir
			for i in range(trainer.trainer_search_range):
				var offset = trainer.position + Global.game.current_scene.position
				match trainer.facing:
					"Up":
						offset += Vector2(0,-32) * (i + 1) 
					"Down":
						offset += Vector2(0, 32) * (i + 1) 
					"Left":
						offset += Vector2(-32, 0) * (i + 1) 
					"Right":
						offset += Vector2(32,  0) * (i + 1) 
				check_positions.append(offset)
			if check_positions.has(self.position):
				print("Player found")
				can_move = false
				emit_signal("trainer_battle", trainer)
				return
	pass

func get_position_relative_to_current_scene() -> Vector2:
	return self.position - Global.game.current_scene.position

func jump() -> void:
	can_move = false
	Global.game.menu.locked = true
	set_process(false)

	move_direction = Vector2.ZERO
	if direction == Direction.DOWN:
		move_direction.y = 64
	if direction == Direction.UP:
		move_direction.y = -64
	if direction == Direction.LEFT:
		move_direction.x = -64
	if direction == Direction.RIGHT:
		move_direction.x = 64

	$Tween.interpolate_property(self, "position", self.position, self.position + move_direction, 0.25, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$AudioStreamPlayer2D.stream = load("res://Audio/SE/jump.wav")
	$AudioStreamPlayer2D.play(0.0)

	$Tween.start()
	$AnimationPlayer.play("Jump")
	yield($Tween, "tween_all_completed")

	var grass_found
	for pos in Global.grass_positions:
		if Global.game.player.position + move_direction == pos: # Should be only one of all grass positions.
			#print("Grass found!")
			grass_found = true

			if !Global.onGrass:
				did_enter_grass = true
			Global.onGrass = true
			break
	if !grass_found: # No grass on next position
		if Global.onGrass:
			did_exit_grass = true
		Global.onGrass = false
	
	set_grass(direction)
	
	can_move = true
	Global.game.menu.locked = false
	set_idle_frame()
	set_process(true)
	
