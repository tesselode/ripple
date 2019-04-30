local ripple = {}

local Instance = {}

function Instance:_updateVolume()
	self._source:setVolume(self._volume * self._sound:_getFinalVolume())
end

function Instance:isLooping()
	return self._source:isLooping()
end

function Instance:setLooping(enabled)
	self._source:setLooping(enabled)
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

function Sound:_getFinalVolume()
	return self._volume
end

function Sound:_updateVolume()
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
	return setmetatable({
		_source = source,
		_volume = options.volume or 1,
		_instances = {},
	}, Sound)
end

return ripple
