extends Node

var icon_container: Icons_Container

var game_state: String = "Play"
var actual_score: int = 0
var game_mode: String = "easy"

# Balancing Vars
var spawn_cooldown: float
var fly_speed: float
var tween_duration: float
var tween_distance: float
