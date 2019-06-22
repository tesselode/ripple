local ripple = require 'ripple'

love.audio.setEffect('chorus', {
	type = 'chorus',
})

local testSound = ripple.newSound(love.audio.newSource('test/bloop.ogg', 'static'))

function love.keypressed(key)
	if key == '1' then
		testSound:play {
			effects = {chorus = true},
		}
	else
		testSound:play()
	end
end

function love.draw()
	love.graphics.print('Instances: ' .. #testSound._instances)
	love.graphics.print('Memory usage: ' .. math.floor(collectgarbage 'count') .. 'kb', 0, 16)
end
