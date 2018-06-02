local ripple = {}

local Sound = {}
Sound.__index = Sound

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
	for _, instance in ipairs(self.instances) do
		instance.source:setVolume(volume * instance.volume)
	end
end

function Sound:play(options)
	options = options or {}
	self:_removeInstances()
	local instance = {
		source = self.source:clone(),
		volume = options.volume or 1,
	}
	instance.source:setVolume(self.volume * instance.volume)
	instance.source:setPitch(options.pitch or 1)
	instance.source:play()
	table.insert(self.instances, instance)
end

function ripple.newSound(options)
	local sound = setmetatable({
		source = options.source,
		volume = options.volume or 1,
		instances = {},
	}, Sound)
	return sound
end

return ripple