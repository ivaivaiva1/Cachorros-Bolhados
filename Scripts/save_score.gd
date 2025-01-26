extends Resource

@export var easy_score: int = 0
@export var medium_score: int = 0
@export var hard_score: int = 0
@export var extreme_score: int = 0

func save_highscores(new_score: int, game_mode: String):
	var config = ConfigFile.new()
	match game_mode:
		"easy":
			config.set_value("highscore", "easy_score", new_score)
		"medium":
			config.set_value("highscore", "medium_score", new_score)
		"hard":
			config.set_value("highscore", "hard_score", new_score)
		"extreme":
			config.set_value("highscore", "extreme_score", new_score)
	config.save("user://highscores.cfg")
