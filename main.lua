local ripple = require 'ripple'

love.audio.setEffect('reverb', {
	type = 'reverb',
	decaytime = 5,
	gain = .5,
})

love.audio.setEffect('chorus', {
	type = 'chorus',
})

love.audio.setEffect('echo', {
	type = 'echo',
	delay = .5,
	feedback = .5,
})

local sfx = ripple.newTag()
sfx:setEffect 'chorus'
sfx:setEffect 'echo'
sfx:setEffect 'reverb'

local testSound = ripple.newSound {
	source = love.audio.newSource('test/bloop.ogg', 'static'),
	tags = {sfx},
}
local testSound2 = ripple.newSound {
	source = love.audio.newSource('test/bloop2.ogg', 'static'),
}

function love.keypressed(key)
	if key == '1' then testSound:play() end
	if key == '2' then testSound2:play() end

	if key == 'return' then testSound2:tag(sfx) end
end

function love.draw()
	love.graphics.print(#testSound._instances)
end
