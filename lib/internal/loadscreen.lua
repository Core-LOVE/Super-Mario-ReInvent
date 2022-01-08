local loadscreen = {}
loadscreen.thread = thread.create(File.read('lib/loadscreen_default.lua'))
loadscreen.thread:start()

function loadscreen.onLoad()
	channel.get( 'info' ):push('end')
end

function loadscreen.onInit()
	registerFunction(loadscreen, 'onLoad')
end

return loadscreen