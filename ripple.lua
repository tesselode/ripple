local ripple = {}

local Taggable = {}

function Taggable:_getTotalVolume()
	local volume = self.volume
	for tag, _ in pairs(self._tags) do
		volume = volume * tag:_getTotalVolume()
	end
	return volume
end

function Taggable:_onChangeVolume() end

function Taggable:_setVolume(volume)
	self._volume = volume
	self:_onChangeVolume()
end

function Taggable:tag(...)
	for i = 1, select('#', ...) do
		local tag = select(i, ...)
		self._tags[tag] = true
		tag._children[self] = true
	end
	self:_onChangeVolume()
end

function Taggable:untag(...)
	for i = 1, select('#', ...) do
		local tag = select(i, ...)
		self._tags[tag] = nil
		tag._children[self] = nil
	end
	self:_onChangeVolume()
end

function Taggable:__index(key)
	if key == 'volume' then
		return self._volume
	end
	return Taggable[key]
end

function Taggable:__newindex(key, value)
	if key == 'volume' then
		self:_setVolume(value)
	else
		rawset(self, key, value)
	end
end

local Tag = {__newindex = Taggable.__newindex}

function Tag:__index(key)
	if Tag[key] then return Tag[key] end
	return Taggable.__index(self, key)
end

function Tag:_onChangeVolume()
	for child, _ in pairs(self._children) do
		child:_onChangeVolume()
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

local Instance = {__newindex = Taggable.__newindex}

function Instance:__index(key)
	if Instance[key] then return Instance[key] end
	return Taggable.__index(self, key)
end

function Instance:_getTotalVolume()
	local volume = Taggable._getTotalVolume(self)
	volume = volume * self._sound:_getTotalVolume()
	return volume
end

function Instance:_onChangeVolume()
	self._source:setVolume(self:_getTotalVolume())
end

local Sound = {__newindex = Taggable.__newindex}

function Sound:__index(key)
	if Sound[key] then return Sound[key] end
	return Taggable.__index(self, key)
end

function Sound:_onChangeVolume()
	for _, instance in ipairs(self._instances) do
		instance:_onChangeVolume()
	end
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
