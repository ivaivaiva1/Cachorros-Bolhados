extends Node

var icon_container: Icons_Container

var game: game_controller
var current_scene: String 


var adaptive_difficulty: float = 0
var auto_play: bool = false


# Balancing Vars
var spawn_cooldown: float 
var fly_speed: float = 100
var tween_duration: float = 2.5 
var tween_distance: float = 80


# SCENES
const SCENES = {
	MENU = "res://Scenes/Menu.tscn",
	GAME = "res://Scenes/Game.tscn"
}
