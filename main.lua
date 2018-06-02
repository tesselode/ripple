local ripple = require 'ripple'

local master = ripple.newTag()
local sfx = ripple.newTag()

local testSound = ripple.newSound {
	source = love.audio.newSource('cowbell.ogg', 'static'),
}
testSound:tag(sfx)

function love.keypressed(key)
	if key == 'space' then
		testSound:play {
			volume = love.math.random(),
			pitch = .5 + love.math.random(),
		}
	end
	if key == 'return' then
		testSound:tag(master)
	end
	if key == 'left' then
		master.volume = master.volume * .5
	end
	if key == 'right' then
		master.volume = master.volume * 2
	end
	if key == 'down' then
		sfx.volume = sfx.volume * .5
	end
	if key == 'up' then
		sfx.volume = sfx.volume * 2
	end
end

function love.draw()
	love.graphics.print(master.volume)
	love.graphics.print(sfx.volume, 0, 16)
end