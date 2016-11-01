local Instance = {}

function Instance:_updateVolumes()
  self._source:setVolume(self._volume * self._sound:_getFinalVolume())
end

local function newInstance(sound, options)
  options = options or {}
  local instance = {
    _sound = sound,
    _source = sound._source:clone(),
    _volume = options.volume or 1,
  }
  setmetatable(instance, {__index = Instance})
  instance:_updateVolumes()
  instance._source:setPitch(options.pitch or 1)
  instance._source:play()
  return instance
end


local Sound = {}

function Sound:_parseTime(value)
  local time, units = value:match '(.*)([sbm])'
  time = tonumber(time)
  if units == 's' then
    return time
  elseif units == 'b' then
    assert(self._bpm, 'Must set bpm of sound if specifying times in beats or measures')
    return 60/self._bpm * time
  elseif units == 'm' then
    assert(self._bpm, 'Must set bpm of sound if specifying times in beats or measures')
    return 60/self._bpm * time * 4
  end
end

function Sound:_getLength()
  if self._length then
    return self:_parseTime(self._length)
  else
    return self._source:getDuration()
  end
end

function Sound:_setVolume(volume)
  self._volume = volume
  self:_updateVolumes()
end

function Sound:_getFinalVolume()
  local v = self._volume
  for i = 1, #self._tags do
    v = v * self._tags[i]._volume
  end
  return v
end

function Sound:_updateVolumes()
  for i = 1, #self._instances do
    self._instances[i]:_updateVolumes()
  end
end

function Sound:_clean()
  for i = #self._instances, 1, -1 do
    if not self._instances[i]._source:isPlaying() then
      table.remove(self._instances, i)
    end
  end
end

function Sound:_tag(tag)
  table.insert(self._tags, tag)
  tag:_addSound(self)
end

function Sound.onEnd() end

function Sound:play(options)
  self:_clean()
  local instance = newInstance(self, options)
  table.insert(self._instances, instance)
  self._time = 0
  self._playing = true
  for interval, f in pairs(self.every) do
    self._timers[interval] = self:_parseTime(interval)
  end
end

function Sound:update(dt)
  if self._playing then
    self._time = self._time + dt
    for interval, f in pairs(self.every) do
      local t = self._timers
      t[interval] = t[interval] - dt
      while t[interval] <= 0 do
        t[interval] = t[interval] + self:_parseTime(interval)
        f()
      end
    end
    if self._time >= self:_getLength() then
      self._playing = false
      self.onEnd()
    end
  end
end

function Sound:stop()
  for i = 1, #self._instances do
    self._instances[i]._source:stop()
  end
  self._playing = false
  self:_clean()
end

local function newSound(filename, options)
  options = options or {}
  options.tags = options.tags or {}
  local sound = {
    _source = love.audio.newSource(filename),
    _tags = {},
    _bpm = options.bpm,
    _length = options.length,
    _volume = 1,
    _instances = {},
    _playing = false,
    _time = 0,
    _timers = {},
    every = {},
  }
  setmetatable(sound, {
    __index = function(self, k)
      if k == 'volume' then
        return self._volume
      elseif Sound[k] then
        return Sound[k]
      else
        return rawget(self, k)
      end
    end,
    __newindex = function(self, k, v)
      if k == 'volume' then
        self:_setVolume(v)
      else
        rawset(self, k, v)
      end
    end,
  })
  -- todo: add an assert to make sure the tags actually exist
  for i = 1, #options.tags do
    sound:_tag(options.tags[i])
  end
  return sound
end


local Tag = {}

function Tag:_addSound(sound)
  table.insert(self._sounds, sound)
end

function Tag:_setVolume(volume)
  self._volume = volume
  self:_updateVolumes()
end

function Tag:_updateVolumes()
  for i = 1, #self._sounds do self._sounds[i]:_updateVolumes() end
end

local function newTag()
  local tag = {
    _volume = 1,
    _sounds = {},
  }
  setmetatable(tag, {
    __index = function(self, k)
      if k == 'volume' then
        return self._volume
      elseif Tag[k] then
        return Tag[k]
      else
        return rawget(self, k)
      end
    end,
    __newindex = function(self, k, v)
      if k == 'volume' then
        self:_setVolume(v)
      else
        rawset(self, k, v)
      end
    end,
  })
  return tag
end


return {
  newSound = newSound,
  newTag = newTag,
}
