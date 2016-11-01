local ripple = require 'ripple'

local testSound = ripple.newSound 'boop.ogg'

function love.keypressed(key)
  if key == 'p' then
    testSound:play {
      pitch = 2,
    }
  end
  if key == 's' then testSound:stop() end
  if key == 'escape' then love.event.quit() end
end

function love.draw()
  love.graphics.print(#testSound._instances)
end
