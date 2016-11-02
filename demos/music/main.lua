local suit = require 'suit'

local ripple = require 'ripple'

local tags = {
  main = ripple.newTag(),
  aux = ripple.newTag(),
  master = ripple.newTag()
}

local sounds = {
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
    tags = {tags.main, tags.master},
  }),
  loopAux = ripple.newSound('loop aux.ogg', {
    bpm = 95,
    length = '4m',
    tags = {tags.aux, tags.master},
  }),
}
sounds.introMain.onEnd = function()
  sounds.loopMain:play()
  sounds.loopAux:play()
end
sounds.loopMain.onEnd = function()
  sounds.loopMain:play()
  sounds.loopAux:play()
end
sounds.introMain.every['1m'] = function() flashingBoxes[1].alpha = 255 end
sounds.introMain.every['1b'] = function() flashingBoxes[2].alpha = 255 end
sounds.introMain.every['.5b'] = function() flashingBoxes[3].alpha = 255 end
sounds.loopMain.every['1m'] = function() flashingBoxes[1].alpha = 255 end
sounds.loopMain.every['1b'] = function() flashingBoxes[2].alpha = 255 end
sounds.loopMain.every['.5b'] = function() flashingBoxes[3].alpha = 255 end

local mainSlider = {value = 1, min = 0, max = 1}
local auxSlider = {value = 1, min = 0, max = 1}
local masterSlider = {value = 1, min = 0, max = 1}
flashingBoxes = {{alpha = 0}, {alpha = 0}, {alpha = 0}}

function love.update(dt)
  if suit.Button('Play', 50, 50, 300, 50).hit then
    sounds.introMain:play()
    sounds.introAux:play()
  end
  if suit.Button('Stop', 450, 50, 300, 50).hit then
    for _, sound in pairs(sounds) do
      sound:stop()
    end
  end

  suit.Label('Kick + Snare', 50, 150, 100, 20)
  suit.Slider(mainSlider, 200, 150, 550, 20)
  suit.Label('Aux percussion', 50, 190, 100, 20)
  suit.Slider(auxSlider, 200, 190, 550, 20)
  suit.Label('Master', 50, 230, 100, 20)
  suit.Slider(masterSlider, 200, 230, 550, 20)
  tags.main.volume.v = mainSlider.value
  tags.aux.volume.v = auxSlider.value
  tags.master.volume.v = masterSlider.value

  for i = 1, #flashingBoxes do
    flashingBoxes[i].alpha = flashingBoxes[i].alpha - 1000 * dt
    if flashingBoxes[i].alpha < 0 then
      flashingBoxes[i].alpha = 0
    end
  end

  for _, sound in pairs(sounds) do
    sound:update(dt)
  end
end

function love.keypressed(key)
  if key == 'escape' then love.event.quit() end
end


function love.draw()
  suit.draw()
  for i = 1, #flashingBoxes do
    local x = 50 + 100 * (i - 1)
    local y = 290
    local w = 75
    local h = 75
    love.graphics.setColor(255, 255, 255)
    love.graphics.setLineWidth(1)
    love.graphics.rectangle('line', x, y, w, h)
    love.graphics.setColor(255, 255, 255, flashingBoxes[i].alpha)
    love.graphics.rectangle('fill', x, y, w, h)
  end
end
