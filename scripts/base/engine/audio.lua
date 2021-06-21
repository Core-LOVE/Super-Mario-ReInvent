local audio = {}

audio.load = sound.loadAudio

function audio.play(place, name, typ)
	local mus = audio.load(place, name, typ)
	mus:play()
end

_G.Audio = audio