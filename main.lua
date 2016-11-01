local ripple = require 'ripple'

intro = ripple.newSound('intro.ogg', {
  bpm = 95,
  length = '2b',
})
intro.onEnd = function() loop:play() end

loop = ripple.newSound('loop.ogg', {
  bpm = 95,
  length = '2m',
})
loop.onEnd = function() loop:play() end
loop.every['.5b'] = function() print '\t\teigth' end
loop.every['1b'] = function() print '\tbeat' end
loop.every['1m'] = function() print 'measure' end

function love.update(dt)
  intro:update(dt)
  loop:update(dt)
end

function love.keypressed(key)
  if key == 'p' then intro:play() end
  if key == 's' then
    intro:stop()
    loop:stop()
  end

  if key == 'escape' then love.event.quit() end
end
