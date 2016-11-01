local ripple = require 'ripple'

local testSound = ripple.newSound 'boop.ogg'

function love.keypressed(key)
  if key == 'p' then
    testSound:play {
      volume = love.math.random(),
      pitch = 2,
    }
  end
  if key == 's' then testSound:stop() end
  if key == '5' then
    if testSound:_getVolume() == .5 then
      testSound:_setVolume(1)
    else
      testSound:_setVolume(.5)
    end
  end
  if key == 'escape' then love.event.quit() end
end

function love.draw()
  love.graphics.print(#testSound._instances)
end
