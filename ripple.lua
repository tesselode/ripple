local ripple = {}

local Sound = {}
Sound.__index = Sound

function Sound:play()
	self.source:play()
end

function ripple.newSound(options)
	local sound = setmetatable({
		source = options.source,
	}, Sound)
	return sound
end

return ripple