local ripple = {}

local Instance = {}

function Instance:_onChangeVolume()
	self._source:setVolume(self._volume * self._sound._volume)
end

function Instance:__index(key)
	if key == 'volume' then
		return self._volume
	end
	return Instance[key]
end

function Instance:__newindex(key, value)
	if key == 'volume' then
		self._volume = value
		self:_onChangeVolume()
	else
		rawset(self, key, value)
	end
end

local Sound = {}

function Sound:__index(key)
	if key == 'volume' then
		return self._volume
	end
	return Sound[key]
end

function Sound:__newindex(key, value)
	if key == 'volume' then
		self._volume = value
		for _, instance in ipairs(self._instances) do
			instance:_onChangeVolume()
		end
	else
		rawset(self, key, value)
	end
end

function Sound:play(options)
	local instance = setmetatable({
		_sound = self,
		_source = self._source:clone(),
	}, Instance)
	instance.volume = options and options.volume or 1
	instance._source:play()
	table.insert(self._instances, instance)
	return instance
end

function ripple.newSound(source, options)
	local sound = setmetatable({
		_source = source,
		_instances = {},
	}, Sound)
	sound.volume = options and options.volume or 1
	return sound
end

return ripple
