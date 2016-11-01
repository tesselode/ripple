local ripple = require 'ripple'

local testSound = ripple.newSound('boop.ogg', {
  bpm = 180,
  length = '1m',
})
testSound.onEnd = function() testSound:play() end

function love.update(dt)
  testSound:update(dt)
end

function love.keypressed(key)
  if key == 'p' then testSound:play() end
  if key == 's' then testSound:stop() end

  if key == 'escape' then love.event.quit() end
end

function love.draw()
  love.graphics.print(#testSound._children..'\n'..testSound:_getFinalVolume())
end
