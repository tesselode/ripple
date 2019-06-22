local ripple = require 'ripple'

local testSound = ripple.newSound(love.audio.newSource('test/bloop.ogg', 'static'), {
	loop = true,
	defaultFadeDuration = 1,
})

function love.update(dt)
	testSound:update(dt)
end

function love.keypressed(key)
	if key == 'space' then
		testSound:play()
	elseif key == 'p' then
		testSound:pause()
	elseif key == 'r' then
		testSound:resume()
	elseif key == 's' then
		testSound:stop()
	end
end

function love.draw()
	love.graphics.print('Instances: ' .. #testSound._instances)
	love.graphics.print('Memory usage: ' .. math.floor(collectgarbage 'count') .. 'kb', 0, 16)
end
