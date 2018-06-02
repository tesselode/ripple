local ripple = {}

local Sound = {}
Sound.__index = Sound

function Sound:_removeInstances()
	for i = #self.instances, 1, -1 do
		if not self.instances[i]:isPlaying() then
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
		instance:setVolume(volume)
	end
end

function Sound:play()
	self:_removeInstances()
	local instance = self.source:clone()
	instance:setVolume(self.volume)
	instance:play()
	table.insert(self.instances, instance)
end

function ripple.newSound(options)
	local sound = setmetatable({
		source = options.source,
		instances = {},
		volume = 1,
	}, Sound)
	return sound
end

return ripple