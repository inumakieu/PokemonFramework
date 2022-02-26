extends Node

var TrainerName : String = "TrainerName"
var TrainerGender = 0 # 0 is boy, 1 is neutral, 2 is girl
var badges = 0
var time : int = 0 # number of minutes spend in-game
var location : String = ""
var money : int = 0
var pokedex_seen = [] # list of id numbers
var pokedex_caught = [] # list of id numbers

var onStairsUp = false
var onStairsDown = false
var wasOnStairs = false

var debug = true

var onGrass = false
var lookingOnGrass = false
var grass_positions = []
var grassPos = ""
var exitGrassPos = ""
var grassSprite = "res://Graphics/Autotiles/Tall Grass2.png"

var printFPS = false
#var size
var sprint = false
var game : Node

var inventory

var can_run = false

var pokemon_group = [] # Cannot be more that 6 Pokemon objects

var past_events = [] # All events that had occured

var isMobile = false

var load_game_from_id # Used on loading a save

var player_starter # 0 = Raptorch, 1 = Orchynx, 2 = Electux

var block_wild = false

var rng

var registry

