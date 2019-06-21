local ripple = require 'ripple'

love.audio.setEffect('chorus', {
	type = 'chorus',
})

local testSource = love.audio.newSource('test/bloop.ogg', 'static')
local testTag = ripple.newTag {
	effects = {chorus = true},
}
local testSound = ripple.newSound(testSource)

function love.keypressed(key)
	if key == '1' then
		testSound:tag(testTag)
	end
	if key == '2' then
		testSound:untag(testTag)
	end
	if key == 'space' then
		testSound:play()
	end
end
