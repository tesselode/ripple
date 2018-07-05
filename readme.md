# Ripple

Ripple is an audio library for LÖVE that simplifies various aspects of audio handling, including tagging and playing multiple instances of a sound.

## Installation

To use Ripple, place ripple.lua in your project, and then add this code to your main.lua:

```lua
ripple = require 'ripple' -- if your ripple.lua is in the root directory
ripple = require 'path.to.ripple' -- if it's in subfolders
```

## Usage

### Loading sounds

```lua
local sound = ripple.newSound(options)
```

Use `ripple.newSound` to load a sound. `options` is a table with the following keys:
- `source` - the source to use for the sound. Sources can be created using [`love.audio.newSource`](https://love2d.org/wiki/love.audio.newSource).
- `volume` (optional) - the volume of the sound, from 0 to 1. Defaults to 1.
- `tags` (optional) - a list of tags to apply to the sound (see below for more information on tags).

### Playing sounds

```lua
sound:play(options)
```

Plays a sound. `options` is a table with the following keys, all of which are optional:
- `volume` - sets the volume of this particular occurrence of the sound relative to the sound's main volume, from 0 to 1. Defaults to 1.
- `pitch` - the pitch of this particular occurrence of the sound, in terms of a multiple of the default playback speed. Defaults to 1.

### Tagging sounds

To create a tag, use `ripple.newTag`:

```lua
local tag = ripple.newTag()
```

You can then add tags to sounds or remove them from sounds using `sound.tag` and `sound.untag`:

```lua
sound:tag(tag1)
sound:untag(tag2)
```

If you don't want to add or remove tags individually, you can also specify an entire list of tags using `sound.setTags`:

```lua
sound:setTags {tag1, tag2, ...}
```

You can get a list of the tags a sound is currently tagged with using `sound.getTags`:

```lua
local tags = sound:getTags()
```

### Adjusting volume levels

You can adjust the volume of individual sounds by setting the `volume` property of a sound. You can also adjust the volume of a tag by setting its `volume` property. The overall volume level of a sound is its own volume multiplied by the volume of each of its tags. This allows you to easily set the volume of categories of sounds. For example, you could have separate "music" and "sfx" tags, and you can adjust the volume of all music tracks and sound effects at once by setting the volume of their respective tags.

### Looping sounds

You can set whether a sound should loop or not using `sound.setLooping`:

```lua
sound:setLooping(true) -- enables looping
sound:setLooping(false) -- disables looping
```

### Using audio effects

You can set a sound to use an effect defined by [`love.audio.setEffect`](https://love2d.org/wiki/love.audio.setEffect) using `sound.setEffect`:

```lua
sound:setEffect(name, filtersettings)
```

- `name` - the name of the effect to use.
- `filtersettings` (optional) - filter settings to apply to the sound (see [`Source:setEffect`](https://love2d.org/wiki/Source:setEffect)).

You can disable an effect by passing `false` as the second argument.

You can also set effects on tags using `tag.setEffect`:

```lua
tag:setEffect(name, filtersettings) -- applies an effect
tag:setEffect(false) -- removes an effect
```

Effects applied to a tag will override the effects already on individual sounds.
