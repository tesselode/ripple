local ripple = require 'ripple'

local testSound = ripple.newSound {
	source = love.audio.newSource('cowbell.ogg', 'static'),
}

function love.keypressed(key)
	if key == 'space' then
		testSound:play()
	end
	if key == 'down' then
		testSound:setVolume(testSound:getVolume() * .5)
	end
	if key == 'up' then
		testSound:setVolume(testSound:getVolume() * 2)
	end
end

function love.draw()
	love.graphics.print(#testSound.instances)
end