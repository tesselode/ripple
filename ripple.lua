local ripple = {}

local Tag = {}

function Tag:__index(k)
	if k == 'volume' then
		return self:getVolume()
	elseif rawget(self, k) then
		return rawget(self, k)
	else
		return Tag[k]
	end
end

function Tag:__newindex(k, v)
	if k == 'volume' then
		self:setVolume(v)
	else
		rawset(self, k, v)
	end
end

function Tag:_addSound(sound)
	self._sounds[sound] = true
end

function Tag:_removeSound(sound)
	self._sounds[sound] = nil
end

function Tag:getVolume()
	return self._volume
end

function Tag:setVolume(volume)
	self._volume = volume
	for sound, _ in pairs(self._sounds) do
		sound:_updateVolume()
	end
end

function ripple.newTag()
	return setmetatable({
		_volume = 1,
		_sounds = {},
	}, Tag)
end

local Sound = {}

function Sound:__index(k)
	if k == 'volume' then
		return self:getVolume()
	elseif rawget(self, k) then
		return rawget(self, k)
	else
		return Sound[k]
	end
end

function Sound:__newindex(k, v)
	if k == 'volume' then
		self:setVolume(v)
	else
		rawset(self, k, v)
	end
end

function Sound:_updateVolume()
	self._finalVolume = self._volume
	for tag, _ in pairs(self._tags) do
		self._finalVolume = self._finalVolume * tag:getVolume()
	end
	for instance, _ in pairs(self._instances) do
		instance.source:setVolume(self._finalVolume * instance.volume)
	end
end

function Sound:_removeInstances()
	for instance, _ in pairs(self._instances) do
		if not instance.source:isPlaying() then
			self._instances[instance] = nil
		end
	end
end

function Sound:getVolume()
	return self._volume
end

function Sound:setVolume(volume)
	self._volume = volume
	self:_updateVolume()
end

function Sound:tag(tag)
	self._tags[tag] = true
	tag:_addSound(self)
	self:_updateVolume()
end

function Sound:untag(tag)
	self._tags[tag] = nil
	tag:_removeSound(self)
	self:_updateVolume()
end

function Sound:play(options)
	options = options or {}
	self:_removeInstances()
	local instance = {
		source = self.source:clone(),
		volume = options.volume or 1,
	}
	instance.source:setVolume(self._finalVolume * instance.volume)
	instance.source:setPitch(options.pitch or 1)
	instance.source:play()
	self._instances[instance] = true
end

function ripple.newSound(options)
	local sound = setmetatable({
		source = options.source,
		_volume = options.volume or 1,
		_tags = {},
		_instances = {},
	}, Sound)
	return sound
end

return ripple