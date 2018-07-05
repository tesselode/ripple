local ripple = {}

local Tag = {}

function Tag:__index(k)
	return k == 'volume' and self:_getVolume()
		or rawget(self, k)
		or Tag[k]
end

function Tag:__newindex(k, v)
	if k == 'volume' then
		self:_setVolume(v)
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

function Tag:_getVolume()
	return self._volume
end

function Tag:_setVolume(volume)
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
	return k == 'volume' and self:_getVolume()
		or k == 'tags' and self:getTags()
		or rawget(self, k)
		or Sound[k]
end

function Sound:__newindex(k, v)
	if k == 'volume' then
		self:_setVolume(v)
	elseif k == 'tags' then
		self:setTags(v)
	else
		rawset(self, k, v)
	end
end

function Sound:_updateVolume()
	self._finalVolume = self._volume
	for tag, _ in pairs(self._tags) do
		self._finalVolume = self._finalVolume * tag:_getVolume()
	end
	for _, instance in ipairs(self._instances) do
		instance.source:setVolume(self._finalVolume * instance.volume)
	end
end

function Sound:_removeInstances()
	for i = #self._instances, 1, -1 do
		if not self._instances[i].source:isPlaying() then
			table.remove(self._instances, i)
		end
	end
end

function Sound:_getVolume()
	return self._volume
end

function Sound:_setVolume(volume)
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

function Sound:getTags()
	local tags = {}
	for tag, _ in pairs(self._tags) do
		table.insert(tags, tag)
	end
	return tags
end

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
	self:_removeInstances()
	local instance = {
		source = self.source:clone(),
		volume = options.volume or 1,
	}
	instance.source:setVolume(self._finalVolume * instance.volume)
	instance.source:setPitch(options.pitch or 1)
	instance.source:play()
	table.insert(self._instances, instance)
end

function ripple.newSound(options)
	local sound = setmetatable({
		source = options.source,
		_volume = options.volume or 1,
		_tags = {},
		_instances = {},
	}, Sound)
	sound:setTags(options.tags or {})
	return sound
end

return ripple
