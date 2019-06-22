local ripple = require 'ripple'

local testSound = ripple.newSound(love.audio.newSource('test/bloop.ogg', 'static'), {
	loop = true,
})

function love.keypressed(key)
	if key == 'space' then
		instance = testSound:play()
	elseif key == 's' then
		if instance then instance:stop() end
	elseif key == 'p' then
		if instance then instance:pause() end
	elseif key == 'r' then
		if instance then instance:resume() end
	elseif key == 'a' then
		testSound:stop()
	end
end

function love.draw()
	love.graphics.print('Instances: ' .. #testSound._instances)
	love.graphics.print('Memory usage: ' .. math.floor(collectgarbage 'count') .. 'kb', 0, 16)
end
