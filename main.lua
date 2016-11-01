local ripple = require 'ripple'

local testTagA = ripple.newTag()
local testTagB = ripple.newTag()
testTagB.volume = .5
local testSound = ripple.newSound('boop.ogg', {
  bpm = 180,
  length = '1b',
  tags = {testTagA, testTagB},
})

function testSound.onEnd()
  testSound:play()
end

function love.update(dt)
  testSound:update(dt)
end

function love.keypressed(key)
  if key == 'p' then testSound:play() end
  if key == 's' then testSound:stop() end
  if key == '5' then testTagA.volume = .5 end
  if key == '1' then testSound.volume = .1 end

  if key == 'escape' then love.event.quit() end
end

function love.draw()
  love.graphics.print(#testSound._instances..'\n'..testTagB.volume)
end
