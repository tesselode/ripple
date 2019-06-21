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

--[[
	Gets the total volume of this object given its own volume
	and the volume of each of its tags.
]]
function Taggable:_getTotalVolume()
	local volume = self.volume
	for tag, _ in pairs(self._tags) do
		volume = volume * tag:_getTotalVolume()
	end
	return volume
end

--[[
	Gets all the effects that should be applied to this object given
	its own effects and the effects of each of its tags. The object's
	own effects will override tag effects.

	Note: currently, if multiple tags define settings for the same effect,
	the final result is undefined, as taggable objects use pairs to iterate
	through the tags, which iterates in an undefined order.
]]
function Taggable:_getAllEffects()
	local effects = {}
	for tag, _ in pairs(self._tags) do
		for name, filterSettings in pairs(tag:_getAllEffects()) do
			effects[name] = filterSettings
		end
	end
	for name, filterSettings in pairs(self._effects) do
		effects[name] = filterSettings
	end
	return effects
end

--[[
	A callback that is called when anything happens that could
	lead to a change in the object's total volume.
]]
function Taggable:_onChangeVolume() end

--[[
	A callback that is called when anything happens that could
	change which effects are applied to the object.
]]
function Taggable:_onChangeEffects() end

function Taggable:_setVolume(volume)
	self._volume = volume
	self:_onChangeVolume()
end

--[[
	Given an options table, initializes the object's volume,
	tags, and effects.
]]
function Taggable:_setOptions(options)
	self.volume = options and options.volume or 1
	if options and options.tags then
		self:tag(unpack(options.tags))
	end
	if options and options.effects then
		for name, filterSettings in pairs(options.effects) do
			self:setEffect(name, filterSettings)
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

--[[
	Sets an effect for this object. filterSettings can be the following types:
	- table - the effect will be enabled with the filter settings given in the table
	- true/nil - the effect will be enabled with no filter
	- false - the effect will be explicitly disabled, overriding effect settings
	from a parent sound or tag
]]
function Taggable:setEffect(name, filterSettings)
	if filterSettings == nil then filterSettings = true end
	self._effects[name] = filterSettings
	self:_onChangeEffects()
end

function Taggable:removeEffect(name)
	self._effects[name] = nil
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

--[[
	Represents a tag that can be applied to sounds,
	instances of sounds, or other tags.
]]
local Tag = {__newindex = Taggable.__newindex}

function Tag:__index(key)
	if Tag[key] then return Tag[key] end
	return Taggable.__index(self, key)
end

function Tag:_onChangeVolume()
	-- tell children about a potential volume change
	for child, _ in pairs(self._children) do
		child:_onChangeVolume()
	end
end

function Tag:_onChangeEffect()
	-- tell children about a potential effect change
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

-- Represents a specific occurrence of a sound.
local Instance = {__newindex = Taggable.__newindex}

function Instance:__index(key)
	if Instance[key] then return Instance[key] end
	return Taggable.__index(self, key)
end

function Instance:_getTotalVolume()
	local volume = Taggable._getTotalVolume(self)
	-- apply sound volume as well as tag/self volumes
	volume = volume * self._sound:_getTotalVolume()
	return volume
end

function Instance:_getAllEffects()
	local effects = {}
	for tag, _ in pairs(self._tags) do
		for name, filterSettings in pairs(tag:_getAllEffects()) do
			effects[name] = filterSettings
		end
	end
	-- apply sound effects as well as tag/self effects
	for name, filterSettings in pairs(self._sound:_getAllEffects()) do
		effects[name] = filterSettings
	end
	for name, filterSettings in pairs(self._effects) do
		effects[name] = filterSettings
	end
	return effects
end

function Instance:_onChangeVolume()
	-- update the source's volume
	self._source:setVolume(self:_getTotalVolume())
end

function Instance:_onChangeEffects()
	-- get the list of effects that should be applied
	local effects = self:_getAllEffects()
	for name, filterSettings in pairs(effects) do
		-- remember which effects are currently applied to the source
		if filterSettings == false then
			self._appliedEffects[name] = nil
		else
			self._appliedEffects[name] = true
		end
		if filterSettings == true then
			self._source:setEffect(name)
		else
			self._source:setEffect(name, filterSettings)
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

-- Represents a sound that can be played.
local Sound = {__newindex = Taggable.__newindex}

function Sound:__index(key)
	if Sound[key] then return Sound[key] end
	return Taggable.__index(self, key)
end

function Sound:_onChangeVolume()
	-- tell instances about potential volume changes
	for _, instance in ipairs(self._instances) do
		instance:_onChangeVolume()
	end
end

function Sound:_onChangeEffects()
	-- tell instances about potential effect changes
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
