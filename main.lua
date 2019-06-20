local ripple = require 'ripple'

local testSound = ripple.newSound(love.audio.newSource('test/bloop.ogg', 'static'))

function love.keypressed(key)
	if key == 'space' then
		instance = testSound:play()
	elseif instance then
		instance.volume = instance.volume * .5
	end
end
