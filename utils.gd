class_name Utils

static func parse_lyrics_to_tokens(lyrics: String) -> Array[PackedStringArray]:
	var lines := lyrics.split("\n", false)
	var ret : Array[PackedStringArray] = []
	
	for line in lines:
#		line = line.replace("(", " ")
#		line = line.replace(")", " ")
#		line = line.replace("-", " ")
		ret.append(line.split(" ", false))
	return ret
	
