local ripple = require 'ripple'

love.audio.setEffect('cavern', {
	type = 'reverb',
	decaytime = 5,
	gain = .5,
})

local testSound = ripple.newSound {
	source = love.audio.newSource('bloop.ogg', 'static'),
}

testSound:setEffect 'cavern'

function love.keypressed(key)
	if key == 'space' then
		testSound:play {
			volume = .5 + .5 * love.math.random(),
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
