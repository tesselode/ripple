local ripple = {}

local unpack = unpack or table.unpack -- luacheck: ignore

--[[
	Represents an object that:
	- can have tags applied
	- has a volume
	- can have effects applied

	Tags, instances, and sounds are all taggable.

	Note that not all taggable objects have children - tags and sounds
	do, but instances do not.
]]
local Taggable = {}

function Taggable:_getTotalVolume()
	local volume = self.volume
	for tag, _ in pairs(self._tags) do
		volume = volume * tag:_getTotalVolume()
	end
	return volume
end

function Taggable:_getAllEffects()
	local effects = {}
	for tag, _ in pairs(self._tags) do
		for name, properties in pairs(tag:_getAllEffects()) do
			effects[name] = properties
		end
	end
	for name, properties in pairs(self._effects) do
		effects[name] = properties
	end
	return effects
end

function Taggable:_onChangeVolume() end

function Taggable:_onChangeEffects() end

function Taggable:_setVolume(volume)
	self._volume = volume
	self:_onChangeVolume()
end

function Taggable:_setOptions(options)
	self.volume = options and options.volume or 1
	if options and options.tags then
		self:tag(unpack(options.tags))
	end
	if options and options.effects then
		for name, properties in pairs(options.effects) do
			self:setEffect(name, properties)
		end
	end
end

function Taggable:tag(...)
	for i = 1, select('#', ...) do
		local tag = select(i, ...)
		self._tags[tag] = true
		tag._children[self] = true
	end
	self:_onChangeVolume()
	self:_onChangeEffects()
end

function Taggable:untag(...)
	for i = 1, select('#', ...) do
		local tag = select(i, ...)
		self._tags[tag] = nil
		tag._children[self] = nil
	end
	self:_onChangeVolume()
	self:_onChangeEffects()
end

function Taggable:setEffect(name, properties)
	self._effects[name] = properties
	self:_onChangeEffects()
end

function Taggable:getEffect(name)
	return self._effects[name]
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

function Tag:_onChangeEffect()
	for child, _ in pairs(self._children) do
		child:_onChangeEffect()
	end
end

function ripple.newTag(options)
	local tag = setmetatable({
		_effects = {},
		_tags = {},
		_children = {},
	}, Tag)
	tag:_setOptions(options)
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

function Instance:_getAllEffects()
	local effects = {}
	for tag, _ in pairs(self._tags) do
		for name, properties in pairs(tag:_getAllEffects()) do
			effects[name] = properties
		end
	end
	for name, properties in pairs(self._sound:_getAllEffects()) do
		effects[name] = properties
	end
	for name, properties in pairs(self._effects) do
		effects[name] = properties
	end
	return effects
end

function Instance:_onChangeVolume()
	self._source:setVolume(self:_getTotalVolume())
end

function Instance:_onChangeEffects()
	-- get the list of effects that should be applied
	local effects = self:_getAllEffects()
	for name, properties in pairs(effects) do
		-- remember which effects are currently applied to the source
		if properties == false then
			self._appliedEffects[name] = nil
		else
			self._appliedEffects[name] = true
		end
		if properties == true then
			self._source:setEffect(name)
		else
			self._source:setEffect(name, properties)
		end
	end
	-- remove effects that are currently applied but shouldn't be anymore
	for name in pairs(self._appliedEffects) do
		if not effects[name] then
			self._source:setEffect(name, false)
			self._appliedEffects[name] = nil
		end
	end
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

function Sound:_onChangeEffects()
	for _, instance in ipairs(self._instances) do
		instance:_onChangeEffects()
	end
end

function Sound:play(options)
	local instance = setmetatable({
		_sound = self,
		_source = self._source:clone(),
		_effects = {},
		_tags = {},
		_appliedEffects = {},
	}, Instance)
	instance:_setOptions(options)
	instance:_onChangeEffects()
	instance._source:play()
	table.insert(self._instances, instance)
	return instance
end

function ripple.newSound(source, options)
	local sound = setmetatable({
		_source = source,
		_effects = {},
		_tags = {},
		_instances = {},
	}, Sound)
	sound:_setOptions(options)
	return sound
end

return ripple
