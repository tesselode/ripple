local ripple = require 'ripple'

local testTagA = ripple.newTag()
local testTagB = ripple.newTag()
testTagB:_setVolume(.1)

local testSound = ripple.newSound('boop.ogg')

function love.keypressed(key)
  if key == 'p' then
    testSound:play {
      volume = love.math.random(),
      pitch = 2,
    }
  end
  if key == 's' then testSound:stop() end
  if key == '5' then testTagA:_setVolume(.5) end
  if key == 'a' then testSound:tag(testTagA) end
  if key == 'b' then testSound:tag(testTagB) end

  if key == 'escape' then love.event.quit() end
end

function love.draw()
  love.graphics.print(#testSound._children..'\n'..testSound:_getFinalVolume())
end
