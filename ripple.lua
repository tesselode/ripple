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

function Sound:_clean()
  removeByFilter(self._children, function(instance)
    return not instance._source:isPlaying()
  end)
end

function Sound:play(options)
  self:_clean()
  local instance = newInstance(self, options)
end

function Sound:stop()
  for i = 1, #self._children do
    self._children[i]:_stop()
  end
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
  }, {__index = Sound})
  return sound
end


ripple.newTag = newTag
ripple.newSound = newSound
return ripple
