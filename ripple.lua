local ripple = {}


local function removeByValue(t, v)
  for i = #t, 1, -1 do
    if t[i] == v then
      table.remove(t, i)
    end
  end
end

local function removeByFilter(t, f)
  for i = #t, 1, -1 do
    if f(t[i]) then
      table.remove(t, i)
    end
  end
end


local Tag = {}

function Tag:_addChild(child)
  table.insert(self._children, child)
end

function Tag:_removeChild(child)
  removeByValue(self._children, child)
end

function Tag:_updateVolume()
  for i = 1, #self._children do
    self._children[i]:_updateVolume()
  end
end

function Tag:_getVolume()
  return self._volume
end

function Tag:_setVolume(volume)
  self._volume = volume
  self:_updateVolume()
end

function Tag:_getFinalVolume()
  local v = self._volume
  for i = 1, #self._parents do
    v = v * self._parents[i]:_getFinalVolume()
  end
  return v
end

function Tag:tag(tag)
  table.insert(self._parents, tag)
  tag:_addChild(self)
  self:_updateVolume()
end

function Tag:untag(tag)
  removeByValue(self._parents, tag)
  tag:_removeChild(self)
  self:_updateVolume()
end

local function newTag()
  local tag = setmetatable({
    _children = {},
    _parents = {},
    _volume = 1,
  }, {__index = Tag})
  return tag
end


local Instance = setmetatable({}, {__index = Tag})

function Instance:_updateVolume()
  self._source:setVolume(self:_getFinalVolume())
end

function Instance:_stop()
  self._source:stop()
end

local function newInstance(sound, options)
  options = options or {}
  local instance = setmetatable({
    _children = {},
    _parents = {},
    _volume = options.volume or 1,
    _source = sound._source:clone(),
  }, {__index = Instance})
  instance:tag(sound)
  instance:_updateVolume()
  instance._source:setPitch(options.pitch or 1)
  instance._source:play()
  return instance
end


local Sound = setmetatable({}, {__index = Tag})

function Sound:_parseTime(value)
  local time, units = value:match '(.*)([sbm])'
  time = tonumber(time)
  if units == 's' then
    return time
  elseif units == 'b' then
    assert(self._bpm, 'Must set the BPM to use beats and measures as units')
    return 60/self._bpm * time
  elseif units == 'm' then
    assert(self._bpm, 'Must set the BPM to use beats and measures as units')
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

function Sound:_clean()
  removeByFilter(self._children, function(instance)
    return not instance._source:isPlaying()
  end)
end

function Sound.onEnd() end

function Sound:play(options)
  self:_clean()
  local instance = newInstance(self, options)
  self._playing = true
  self._time = 0
end

function Sound:update(dt)
  if self._playing then
    self._time = self._time + dt
    if self._time >= self:_getLength() then
      self._playing = false
      self.onEnd()
    end
  end
end

function Sound:stop()
  for i = 1, #self._children do
    self._children[i]:_stop()
  end
  self._playing = false
  self:_clean()
end

local function newSound(filename, options)
  options = options or {}
  options.tags = options.tags or {}
  local sound = setmetatable({
    _children = {},
    _parents = {},
    _volume = 1,
    _source = love.audio.newSource(filename),
    _bpm = options.bpm,
    _length = options.length,
    _playing = false,
    _time = 0,
  }, {__index = Sound})
  return sound
end


ripple.newTag = newTag
ripple.newSound = newSound
return ripple
