local ripple = {
	_VERSION = 'ripple',
	_DESCRIPTION = 'Sound manager with tag suppot for LÖVE.',
	_URL = 'https://github.com/tesselode/ripple',
	_LICENSE = [[
		MIT License

		Copyright (c) 2018 Andrew Minnich

		Permission is hereby granted, free of charge, to any person obtaining a copy
		of this software and associated documentation files (the "Software"), to deal
		in the Software without restriction, including without limitation the rights
		to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
		copies of the Software, and to permit persons to whom the Software is
		furnished to do so, subject to the following conditions:

		The above copyright notice and this permission notice shall be included in all
		copies or substantial portions of the Software.

		THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
		IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
		FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
		AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
		LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
		OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
		SOFTWARE.
	]]
}

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
	for name, effect in pairs(self._effects) do
		sound:setEffect(name, effect.filter)
	end
end

function Tag:_removeSound(sound)
	self._sounds[sound] = nil
	for name, _ in pairs(self._effects) do
		sound:setEffect(name, false)
	end
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

function Tag:setEffect(name, filter)
	if filter == false and self._effects[name] then
		for sound, _ in pairs(self._sounds) do
			sound:setEffect(name, false)
		end
		self._effects[name] = nil
	else
		self._effects[name] = {filter = filter}
		for sound, _ in pairs(self._sounds) do
			sound:setEffect(name, filter)
		end
	end
end

function Tag:stop()
	for sound, _ in pairs(self._sounds) do
		sound:stop()
	end
end

function Tag:pause()
	for sound, _ in pairs(self._sounds) do
		sound:pause()
	end
end

function Tag:resume()
	for sound, _ in pairs(self._sounds) do
		sound:resume()
	end
end

function ripple.newTag()
	return setmetatable({
		_volume = 1,
		_sounds = {},
		_effects = {},
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
		local source = self._instances[i].source
		if not source:isPlaying() and source:tell() == 0 then
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

function Sound:isLooping()
	return self._source:isLooping()
end

function Sound:setLooping(enabled)
	if enabled then
		self._source:setLooping(true)
	else
		self._source:setLooping(false)
		for _, instance in ipairs(self._instances) do
			instance.source:setLooping(false)
		end
	end
end

function Sound:setEffect(...)
	self._source:setEffect(...)
end

function Sound:resume()
	self:_removeInstances()
	for _, instance in ipairs(self._instances) do
		instance.source:play()
	end
end

function Sound:play(options)
	self:resume()
	options = options or {}
	local instance = {
		source = self._source:clone(),
		volume = options.volume or 1,
	}
	instance.source:setVolume(self._finalVolume * instance.volume)
	instance.source:setPitch(options.pitch or 1)
	instance.source:seek(options.seek or 0)
	instance.source:play()
	table.insert(self._instances, instance)
end

function Sound:stop()
	for _, instance in ipairs(self._instances) do
		instance.source:stop()
	end
	self:_removeInstances()
end

function Sound:pause()
	for _, instance in ipairs(self._instances) do
		instance.source:pause()
	end
	self:_removeInstances()
end

function ripple.newSound(options)
	local sound = setmetatable({
		_source = options.source,
		_volume = options.volume or 1,
		_tags = {},
		_instances = {},
	}, Sound)
	sound:setTags(options.tags or {})
	sound:_updateVolume()
	return sound
end

return ripple
