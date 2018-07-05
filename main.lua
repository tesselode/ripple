local ripple = require 'ripple'

local testSound = ripple.newSound {
	source = love.audio.newSource('cowbell.ogg', 'static'),
}

function love.keypressed(key)
	if key == 'space' then
		testSound:play {
			volume = love.math.random(),
			pitch = .5 + love.math.random(),
		}
	end
	if key == 'return' then
		testSound:stop()
	end
	if key == 'p' then testSound:pause() end
	if key == 'r' then testSound:resume() end
end

function love.draw()
	love.graphics.print(#testSound._instances)
end
