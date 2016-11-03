local suit = require 'suit'

-- load ripple
local ripple = require 'ripple'

-- tags
local tags = {
  main = ripple.newTag(),
  aux = ripple.newTag(),
  master = ripple.newTag()
}

-- sounds
local sounds = {
  cowbell = ripple.newSound('cowbell.ogg', {
    tags = {tags.master},
  }),
  introMain = ripple.newSound('intro main.ogg', {
    bpm = 95,
    length = '2b',
    tags = {tags.main, tags.master},
  }),
  introAux = ripple.newSound('intro aux.ogg', {
    bpm = 95,
    length = '2b',
    tags = {tags.aux, tags.master},
  }),
  loopMain = ripple.newSound('loop main.ogg', {
    bpm = 95,
    length = '4m',
    loop = true,
    tags = {tags.main, tags.master},
  }),
  loopAux = ripple.newSound('loop aux.ogg', {
    bpm = 95,
    length = '4m',
    loop = true,
    tags = {tags.aux, tags.master},
  }),
}
-- start loop after intro
sounds.introMain.onEnd = function()
  sounds.loopMain:play()
  sounds.loopAux:play()
end
-- make the squares flash
sounds.introMain.every['1m'] = function() flashingBoxes[1].alpha = 255 end
sounds.introMain.every['1b'] = function() flashingBoxes[2].alpha = 255 end
sounds.introMain.every['.5b'] = function() flashingBoxes[3].alpha = 255 end
sounds.loopMain.every['1m'] = function() flashingBoxes[1].alpha = 255 end
sounds.loopMain.every['1b'] = function() flashingBoxes[2].alpha = 255 end
sounds.loopMain.every['.5b'] = function() flashingBoxes[3].alpha = 255 end

-- the rest is just the code that makes the demo work
local mainSlider = {value = 1, min = 0, max = 1}
local auxSlider = {value = 1, min = 0, max = 1}
local masterSlider = {value = 1, min = 0, max = 1}
flashingBoxes = {{alpha = 0}, {alpha = 0}, {alpha = 0}}

function love.update(dt)
  suit.layout:reset(50, 50, 25)

  suit.layout:push(suit.layout:row(700, 50))
  if suit.Button('Play', suit.layout:col(650/3, 50)).hit then
    sounds.introMain:play()
    sounds.introAux:play()
  end
  if suit.Button('Cowbell', suit.layout:col()).hit then
    sounds.cowbell:play {
      volume = love.math.random()*.5 + .5,
      pitch = love.math.random()*.5 + .5,
    }
  end
  if suit.Button('Stop', suit.layout:col()).hit then
    for _, sound in pairs(sounds) do
      sound:stop()
    end
  end
  suit.layout:pop()

  suit.layout:push(suit.layout:row(700, 20))
  suit.Label('Kick + snare', suit.layout:col(100, 20))
  suit.Slider(mainSlider, suit.layout:col(575, 20))
  suit.layout:pop()
  suit.layout:push(suit.layout:row(700, 20))
  suit.Label('Aux percussion', suit.layout:col(100, 20))
  suit.Slider(auxSlider, suit.layout:col(575, 20))
  suit.layout:pop()
  suit.layout:push(suit.layout:row(700, 20))
  suit.Label('Master', suit.layout:col(100, 20))
  suit.Slider(masterSlider, suit.layout:col(575, 20))
  suit.layout:pop()

  tags.main.volume.v = mainSlider.value
  tags.aux.volume.v = auxSlider.value
  tags.master.volume.v = masterSlider.value

  for i = 1, #flashingBoxes do
    flashingBoxes[i].alpha = flashingBoxes[i].alpha - 1000 * dt
    if flashingBoxes[i].alpha < 0 then
      flashingBoxes[i].alpha = 0
    end
  end

  -- update all sounds
  for _, sound in pairs(sounds) do
    sound:update(dt)
  end
end

function love.keypressed(key)
  if key == 'escape' then love.event.quit() end
end

function love.draw()
  suit.draw()
  suit.layout:push(suit.layout:row(700, 75))
  for i = 1, #flashingBoxes do
    local x, y = suit.layout:col(75, 75)
    local w = 75
    local h = 75
    love.graphics.setColor(255, 255, 255)
    love.graphics.setLineWidth(1)
    love.graphics.rectangle('line', x, y, w, h)
    love.graphics.setColor(255, 255, 255, flashingBoxes[i].alpha)
    love.graphics.rectangle('fill', x, y, w, h)
  end
  suit.layout:pop()
end
