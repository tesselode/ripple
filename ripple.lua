local Instance = {}

function Instance:_isPlaying() return self._source:isPlaying() end

function Instance:_update()
  self._source:setVolume(self._volume * self._sound:_getFinalVolume())
end

function Instance:_stop() self._source:stop() end

local function newInstance(sound, options)
  options = options or {}
  local instance = {
    _sound = sound,
    _source = sound._source:clone(),
    _volume = options.volume or 1,
  }
  setmetatable(instance, {__index = Instance})
  instance:_update()
  instance._source:setPitch(options.pitch or 1)
  instance._source:play()
  return instance
end


local Sound = {}

function Sound:_getVolume() return self._volume end

function Sound:_setVolume(volume)
  self._volume = volume
  self:_update()
end

function Sound:_getFinalVolume()
  return self._volume
end

function Sound:_update()
  for i = 1, #self._instances do
    self._instances[i]:_update()
  end
end

function Sound:_clean()
  for i = #self._instances, 1, -1 do
    if not self._instances[i]:_isPlaying() then
      table.remove(self._instances, i)
    end
  end
end

function Sound:play(options)
  self:_clean()
  local instance = newInstance(self, options)
  table.insert(self._instances, instance)
end

function Sound:stop()
  for i = 1, #self._instances do
    self._instances[i]:_stop()
  end
  self:_clean()
end

local function newSound(filename, tags)
  local sound = {
    _source = love.audio.newSource(filename),
    _tags = tags or {},
    _volume = 1,
    _instances = {},
  }
  setmetatable(sound, {__index = Sound})
  return sound
end


return {
  newSound = newSound,
}
