local ripple = require 'ripple'

local testTag = ripple.newTag()

local testSound = ripple.newSound(love.audio.newSource('test/bloop.ogg', 'static'), {
	loop = true,
	tags = {testTag},
})

function love.update(dt)
	testSound:update(dt)
end

function love.keypressed(key)
	if key == 'space' then
		testSound:play()
	elseif key == 'p' then
		testTag:pause(1)
	elseif key == 'r' then
		testTag:resume(1)
	elseif key == 's' then
		testTag:stop(1)
	end
end

function love.draw()
	love.graphics.print('Instances: ' .. #testSound._instances)
	love.graphics.print('Memory usage: ' .. math.floor(collectgarbage 'count') .. 'kb', 0, 16)
end
