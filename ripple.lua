local Instance = {}

function Instance:_update()
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
  instance:_update()
  instance._source:setPitch(options.pitch or 1)
  instance._source:play()
  return instance
end


local Sound = {}

function Sound:_setVolume(volume)
  self._volume = volume
  self:_update()
end

function Sound:_getFinalVolume()
  local v = self._volume
  for i = 1, #self._tags do
    v = v * self._tags[i]._volume
  end
  return v
end

function Sound:_update()
  for i = 1, #self._instances do
    self._instances[i]:_update()
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

function Sound:play(options)
  self:_clean()
  local instance = newInstance(self, options)
  table.insert(self._instances, instance)
end

function Sound:stop()
  for i = 1, #self._instances do
    self._instances[i]._source:stop()
  end
  self:_clean()
end

local function newSound(filename, tags)
  local sound = {
    _source = love.audio.newSource(filename),
    _tags = {},
    _volume = 1,
    _instances = {},
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
  for i = 1, #tags do sound:_tag(tags[i]) end
  return sound
end


local Tag = {}

function Tag:_addSound(sound)
  table.insert(self._sounds, sound)
end

function Tag:_setVolume(volume)
  self._volume = volume
  self:_update()
end

function Tag:_update()
  for i = 1, #self._sounds do self._sounds[i]:_update() end
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
