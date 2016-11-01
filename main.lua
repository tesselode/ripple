local ripple = require 'ripple'

local testSound = ripple.newSound('loop.ogg', {
  bpm = 95,
  length = '2m',
})
testSound.onEnd = function() testSound:play() end
testSound.every['.5b'] = function() print '\t\teigth' end
testSound.every['1b'] = function() print '\tbeat' end
testSound.every['1m'] = function() print 'measure' end

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
