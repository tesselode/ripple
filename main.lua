local ripple = require 'ripple'

local testTag1 = ripple.newTag {volume = .5}
local testTag2 = ripple.newTag {volume = .1}

local testSound = ripple.newSound(love.audio.newSource('test/bloop.ogg', 'static'))

function love.keypressed(key)
	if key == 'space' then
		instance = testSound:play()
	elseif key == '1' then
		testSound:tag(testTag1)
	elseif key == '2' then
		if instance then
			instance:tag(testTag2)
		end
	end
end
