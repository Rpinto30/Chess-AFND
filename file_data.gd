class_name FILEDATA
extends RefCounted
const SAVE_PATH = "user://save_game.json"

# Datos que deseas guardar

static func save_game(game_data: Dictionary):
	var json_string = JSON.stringify(game_data)
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(json_string)
		file.close()
		print("¡Datos guardada con éxito!")

static func load_game() -> Dictionary:
	var game_data =  {}
	# Verificar si el archivo existe antes de cargarlo
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		if file:
			var json_string = file.get_as_text()
			file.close()
			
			# Parsear el texto JSON a un diccionario
			var json = JSON.new()
			var error = json.parse(json_string)
			if error == OK:
				game_data = json.get_data()
				return game_data
				print("¡Partida cargada con éxito!")
			else:
				return {}
				print("Error al analizar el archivo JSON.")
		return {}
	else:
		return {}
		print("No existe un archivo de guardado previo.")
