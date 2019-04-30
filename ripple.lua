local ripple = {}

local Tag = {}

-- Adds a sound to the tag's internal list of sounds
-- and applies the tag effects to the sound if necessary.
function Tag:_addSound(sound)
	self._sounds[sound] = true
	for name, effect in pairs(self._effects) do
		sound:setEffect(name, effect.filter)
	end
end

-- Removes a sound from the tag's internal list of sounds
-- and removes the tag effects from the sound if necessary.
function Tag:_removeSound(sound)
	self._sounds[sound] = nil
	for name, _ in pairs(self._effects) do
		sound:setEffect(name, false)
	end
end

function Tag:_updateVolume()
	for sound, _ in pairs(self._sounds) do
		sound:_updateVolume()
	end
end

-- Sets an effect for a tag and the sounds that have the tag.
-- Removes the effect if filter is false.
function Tag:setEffect(name, filter)
	if filter == false and self._effects[name] then
		for sound, _ in pairs(self._sounds) do
			sound:setEffect(name, false)
		end
		self._effects[name] = nil
	else
		self._effects[name] = {filter = filter}
		for sound, _ in pairs(self._sounds) do
			sound:setEffect(name, filter)
		end
	end
end

-- Pauses all the sounds with the tag.
function Tag:pause()
	for sound, _ in pairs(self._sounds) do
		sound:pause()
	end
end

-- Resumes all the sounds with the tag.
function Tag:resume()
	for sound, _ in pairs(self._sounds) do
		sound:resume()
	end
end

-- Stops all the sounds with the tag.
function Tag:stop()
	for sound, _ in pairs(self._sounds) do
		sound:stop()
	end
end

function Tag:__index(k)
	return k == 'volume' and self._volume()
		or rawget(self, k)
		or Tag[k]
end

function Tag:__newindex(k, v)
	if k == 'volume' then
		self._volume = v
		self:_updateVolume()
	else
		rawset(self, k, v)
	end
end

-- Creates a new tag.
function ripple.newTag()
	return setmetatable({
		_volume = 1,
		_sounds = {},
		_effects = {},
	}, Tag)
end

local Instance = {}

function Instance:_updateVolume()
	self._source:setVolume(self._volume * self._sound._finalVolume)
end

function Instance:isLooping()
	return self._source:isLooping()
end

function Instance:setLooping(enabled)
	self._source:setLooping(enabled)
end

function Instance:setEffect(...)
	self._source:setEffect(...)
end

function Instance:pause()
	self._source:pause()
	self._paused = true
end

function Instance:resume()
	self._source:play()
	self._paused = false
end

function Instance:stop()
	self._source:stop()
	self._paused = false
end

function Instance:isStopped()
	return (not self._source:isPlaying()) and (not self._paused)
end

function Instance:__index(k)
	return k == 'volume' and self._volume
		or k == 'pitch' and self._source:getPitch()
		or rawget(self, k)
		or Instance[k]
end

function Instance:__newindex(k, v)
	if k == 'volume' then
		self._volume = v
		self:_updateVolume()
	elseif k == 'pitch' then
		self._source:setPitch(v)
	else
		rawset(self, k, v)
	end
end

local function newInstance(sound, options)
	options = options or {}
	local instance = setmetatable({
		_sound = sound,
		_source = sound._source:clone(),
		_volume = options.volume or 1,
		_pitch = options.pitch or 1,
		_paused = false,
	}, Instance)
	instance:_updateVolume()
	instance._source:seek(options.seek or 0)
	instance._source:play()
	return instance
end

local Sound = {}

function Sound:_removeFinishedInstances()
	for i = #self._instances, 1, -1 do
		local instance = self._instances[i]
		if instance:isStopped() then
			table.remove(self._instances, i)
		end
	end
end

function Sound:_updateVolume()
	self._finalVolume = self._volume
	for tag, _ in pairs(self._tags) do
		self._finalVolume = self._finalVolume * tag._volume
	end
	for _, instance in ipairs(self._instances) do
		instance:_updateVolume()
	end
end

function Sound:isLooping()
	return self._source:isLooping()
end

-- Sets whether the sound should loop or not.
function Sound:setLooping(enabled)
	self._source:setLooping(enabled)
	if not enabled then
		for _, instance in ipairs(self._instances) do
			instance:setLooping(enabled)
		end
	end
end

function Sound:setEffect(...)
	self._source:setEffect(...)
	for _, instance in ipairs(self._instances) do
		instance:setEffect(...)
	end
end

-- Adds a tag to the sound.
function Sound:tag(tag)
	self._tags[tag] = true
	tag:_addSound(self)
	self:_updateVolume()
end

-- Removes a tag from the sound.
function Sound:untag(tag)
	self._tags[tag] = nil
	tag:_removeSound(self)
	self:_updateVolume()
end

function Sound:getTags()
	local tags = {}
	for tag, _ in pairs(self._tags) do
		table.insert(tags, tag)
	end
	return tags
end

-- Sets the tags the sound should have.
function Sound:setTags(tags)
	for tag, _ in pairs(self._tags) do
		self:untag(tag)
	end
	for _, tag in ipairs(tags) do
		self:tag(tag)
	end
end

function Sound:play(options)
	options = options or {}
	local instance = newInstance(self, options)
	table.insert(self._instances, instance)
	self:_removeFinishedInstances()
	return instance
end

-- Pauses the sound.
function Sound:pause()
	for _, instance in ipairs(self._instances) do
		instance:pause()
	end
	self:_removeFinishedInstances()
end

-- Resumes a paused sound.
function Sound:resume()
	for _, instance in ipairs(self._instances) do
		instance:resume()
	end
	self:_removeFinishedInstances()
end

-- Stops the sound.
function Sound:stop()
	for _, instance in ipairs(self._instances) do
		instance:stop()
	end
	self:_removeFinishedInstances()
end

function Sound:__index(k)
	return k == 'volume' and self._volume
		or rawget(self, k)
		or Sound[k]
end

function Sound:__newindex(k, v)
	if k == 'volume' then
		self._volume = v
		self:_updateVolume()
	else
		rawset(self, k, v)
	end
end

function ripple.newSound(source, options)
	options = options or {}
	if source:typeOf 'SoundData' then
		source = love.audio.newSource(source)
	end
	local sound = setmetatable({
		_source = source,
		_volume = options.volume or 1,
		_tags = {},
		_instances = {},
	}, Sound)
	if options.tags then sound:setTags(options.tags) end
	sound:_updateVolume()
	return sound
end

return ripple
