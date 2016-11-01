local Instance = {}

function Instance:isPlaying() return self._source:isPlaying() end

function Instance:stop() self._source:stop() end

local function newInstance(sound, options)
  options = options or {}
  local instance = {
    _source = sound._source:clone(),
    _volume = options.volume or 1,
  }
  setmetatable(instance, {__index = Instance})
  instance._source:setPitch(options.pitch or 1)
  instance._source:play()
  return instance
end


local Sound = {}

function Sound:_clean()
  for i = #self._instances, 1, -1 do
    if not self._instances[i]._source:isPlaying() then
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
    self._instances[i]:stop()
  end
  self:_clean()
end

local function newSound(filename, tags)
  local sound = {
    _source = love.audio.newSource(filename),
    _tags = tags or {},
    _volume = {},
    _instances = {},
  }
  setmetatable(sound, {__index = Sound})
  return sound
end


return {
  newSound = newSound,
}
