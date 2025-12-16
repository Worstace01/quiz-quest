extends AudioStreamPlayer2D

const level_music = preload("res://Assets/SFX/Medieval Battle Music - Dragon's Lair.mp3")

func _play_music(music: AudioStream, volume = 0.0):
	if stream == music:
		return
		
	stream = music
	volume_db = volume
	play()
	
func play_music_level():
	_play_music(level_music)
	
	
	
