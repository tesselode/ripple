local ripple = {}

local Tag = {}
Tag.__index = Tag

function Tag:_addSound(sound)
	self.sounds[sound] = true
end

function Tag:_removeSound(sound)
	self.sounds[sound] = nil
end

function Tag:getVolume()
	return self.volume
end

function Tag:setVolume(volume)
	self.volume = volume
	for sound, _ in pairs(self.sounds) do
		sound:_updateVolume()
	end
end

function ripple.newTag()
	return setmetatable({
		volume = 1,
		sounds = {},
	}, Tag)
end

local Sound = {}
Sound.__index = Sound

function Sound:_updateVolume()
	self._finalVolume = self.volume
	for tag, _ in pairs(self.tags) do
		self._finalVolume = self._finalVolume * tag:getVolume()
	end
	for _, instance in ipairs(self.instances) do
		instance.source:setVolume(self._finalVolume * instance.volume)
	end
end

function Sound:_removeInstances()
	for i = #self.instances, 1, -1 do
		if not self.instances[i].source:isPlaying() then
			table.remove(self.instances, i)
		end
	end
end

function Sound:getVolume()
	return self.volume
end

function Sound:setVolume(volume)
	self.volume = volume
	self:_updateVolume()
end

function Sound:tag(tag)
	self.tags[tag] = true
	tag:_addSound(self)
	self:_updateVolume()
end

function Sound:untag(tag)
	self.tags[tag] = nil
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
	table.insert(self.instances, instance)
end

function ripple.newSound(options)
	local sound = setmetatable({
		source = options.source,
		volume = options.volume or 1,
		tags = {},
		instances = {},
	}, Sound)
	return sound
end

return ripple