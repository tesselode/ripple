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

local testSound = ripple.newSound {
	source = love.audio.newSource('bloop.ogg', 'static'),
}
testSound:setEffect 'chorus'
testSound:setEffect 'echo'
testSound:setEffect 'reverb'

function love.keypressed(key)
	if key == '1' then testSound:play() end
end

function love.draw()
	love.graphics.print(#testSound._instances)
end
