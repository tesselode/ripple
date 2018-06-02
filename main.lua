local ripple = require 'ripple'

local testSound = ripple.newSound {
	source = love.audio.newSource('cowbell.ogg', 'static'),
}

function love.keypressed(key)
	if key == 'space' then
		testSound:play()
	end
end

function love.draw()
	love.graphics.print(#testSound.instances)
end