local ripple = require 'ripple'

love.audio.setEffect('reverb', {
	type = 'reverb',
	gain = 1,
	decaytime = 5,
})

local testSource = love.audio.newSource('test/bloop.ogg', 'static')
local testTag = ripple.newTag {
	effects = {reverb = true},
}
local testSound = ripple.newSound(testSource)

function love.keypressed(key)
	if key == '1' then
		testSound:tag(testTag)
	end
	if key == 'space' then
		testSound:play {
			effects = {reverb = false},
		}
	end
end
