local ripple = require 'ripple'

love.audio.setEffect('chorus', {
	type = 'chorus',
})

local testSource = love.audio.newSource('test/bloop.ogg', 'static')
local testTag = ripple.newTag {
	effects = {chorus = true},
}
local testSound = ripple.newSound(testSource, {
	tags = {testTag},
	effects = {
		chorus = {
			type = 'lowpass',
			highgain = 0,
		},
	},
})
testSound:removeEffect 'chorus'

function love.keypressed(key)
	if key == 'space' then
		testSound:play()
	end
end
