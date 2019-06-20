local ripple = {}

local Tag = {}

function Tag:_getTotalVolume()
	local volume = self.volume
	for tag, _ in pairs(self._tags) do
		volume = volume * tag:_getTotalVolume()
	end
	return volume
end

function Tag:_onChangeVolume()
	for child, _ in pairs(self._children) do
		child:_onChangeVolume()
	end
end

function Tag:tag(...)
	for i = 1, select('#', ...) do
		local tag = select(i, ...)
		self._tags[tag] = true
		tag._children[self] = true
	end
	self:_onChangeVolume()
end

function Tag:untag(...)
	for i = 1, select('#', ...) do
		local tag = select(i, ...)
		self._tags[tag] = nil
		tag._children[self] = nil
	end
	self:_onChangeVolume()
end

function Tag:__index(key)
	if key == 'volume' then
		return self._volume
	end
	return Tag[key]
end

function Tag:__newindex(key, value)
	if key == 'volume' then
		self._volume = value
		self:_onChangeVolume()
	else
		rawset(self, key, value)
	end
end

function ripple.newTag(options)
	local tag = setmetatable({
		_tags = {},
		_children = {},
	}, Tag)
	tag.volume = options and options.volume or 1
	if options and options.tags then
		tag:tag(unpack(options.tags))
	end
	return tag
end

local Instance = {}

function Instance:_getTotalVolume()
	local volume = self.volume
	for tag, _ in pairs(self._tags) do
		volume = volume * tag:_getTotalVolume()
	end
	volume = volume * self._sound:_getTotalVolume()
	return volume
end

function Instance:_onChangeVolume()
	self._source:setVolume(self:_getTotalVolume())
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

function Instance:tag(...)
	for i = 1, select('#', ...) do
		local tag = select(i, ...)
		self._tags[tag] = true
		tag._children[self] = true
	end
	self:_onChangeVolume()
end

function Instance:untag(...)
	for i = 1, select('#', ...) do
		local tag = select(i, ...)
		self._tags[tag] = nil
		tag._children[self] = nil
	end
	self:_onChangeVolume()
end

local Sound = {}

function Sound:_onChangeVolume()
	for _, instance in ipairs(self._instances) do
		instance:_onChangeVolume()
	end
end

function Sound:_getTotalVolume()
	local volume = self.volume
	for tag, _ in pairs(self._tags) do
		volume = volume * tag:_getTotalVolume()
	end
	return volume
end

function Sound:__index(key)
	if key == 'volume' then
		return self._volume
	end
	return Sound[key]
end

function Sound:__newindex(key, value)
	if key == 'volume' then
		self._volume = value
	else
		rawset(self, key, value)
	end
end

function Sound:tag(...)
	for i = 1, select('#', ...) do
		local tag = select(i, ...)
		self._tags[tag] = true
		tag._children[self] = true
	end
	self:_onChangeVolume()
end

function Sound:untag(...)
	for i = 1, select('#', ...) do
		local tag = select(i, ...)
		self._tags[tag] = nil
		tag._children[self] = nil
	end
	self:_onChangeVolume()
end

function Sound:play(options)
	local instance = setmetatable({
		_sound = self,
		_source = self._source:clone(),
		_tags = {},
	}, Instance)
	instance.volume = options and options.volume or 1
	if options and options.tags then
		instance:tag(unpack(options.tags))
	end
	instance._source:play()
	table.insert(self._instances, instance)
	return instance
end

function ripple.newSound(source, options)
	local sound = setmetatable({
		_source = source,
		_tags = {},
		_instances = {},
	}, Sound)
	sound.volume = options and options.volume or 1
	return sound
end

return ripple
