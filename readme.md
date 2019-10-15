# Ripple

Ripple is an audio library for LÖVE that simplifies various aspects of audio handling, including tagging and playing multiple instances of a sound.

## Installation

To use Ripple, place ripple.lua in your project, and then add this code to your main.lua:

```lua
ripple = require 'ripple' -- if your ripple.lua is in the root directory
ripple = require 'path.to.ripple' -- if it's in subfolders
```

## API

### ripple
This is the main module that lets you create sounds and tags.

#### Functions

##### `local sound = ripple.newSound(source, options)`
Creates a new sound.

Parameters:
- `source` (`Source`) - the source to use for the sound
- `options` (`table`) (optional) - options to apply to the sound. The options table can have the following values:
  - `volume` (`number`) (optional, defaults to `1`) - the volume of the sound, from 0 to 1
  - `tags` (`table`) (optional) - a list of tags to apply to the sound
  - `effects` (`table`) (optional) - the effects to apply to the sound. Each key should be the name of the effect, and each value should be one of the following:
    - `true` - enables the effect without a filter
    - `table` - enables the effect with the filter settings specified in the table
    - `false` - explicitly disables the effect, even if the effect would normally be inherited from a tag
  - `loop` (`boolean`) (optional) - whether the sound should be repeated until stopped

Returns:
- `sound` (`Sound`) - the newly created sound

##### `local tag = ripple.newTag(options)`
Creates a new tag.

Parameters:
- `options` (`table`) (optional) - options to apply to the tag. The options table can have the following values:
  - `volume` (`number`) (optional, defaults to `1`) - the volume of the tag, from 0 to 1
  - `tags` (`table`) (optional) - a list of tags to apply to the tag
  - `effects` (`table`) (optional) - the effects to apply to the tag. Each key should be the name of the effect, and each value should be one of the following:
    - `true` - enables the effect without a filter
    - `table` - enables the effect with the filter settings specified in the table
    - `false` - explicitly disables the effect, even if the effect would normally be inherited from a tag

Returns:
- `tag` (`Tag`) - the newly created tag

### Taggable
This class is not something you create directly, but it does contain functions you can use on any taggable object: sounds, instances, and tags.

#### Properties

##### `Taggable.volume (number)`
The volume of the taggable object from 0 to 1.

#### Functions

##### `Taggable:tag(...)`
Applies one or more tags to a taggable object.

Parameters:
- `...` (`Tag`) - the tags to apply

##### `Taggable:untag(...)`
Removes one or more tags from a taggable object.

Parameters:
- `...` (`Tag`) - the tags to remove

##### `Taggable:setEffect(name, filterSettings)`
Enables or disables an effect on a taggable object.

Parameters:
- `name` (`string`) - the effect to enable or disable
- `filterSettings` (`boolean` or `table`) (optional)
  - `false` - explicitly disables the effect, even if the taggable object would normally inherit the effect
  - `true` - enables the effect without any filter
  - `table` - enables the effect with the given filter settings

##### `Taggable:removeEffect(name)`
Unsets an effects on a taggable object.

Parameters:
- `name` (`string`) - the name of the effect to remove

##### `local effect = Taggable:getEffect(name)`
Gets the effect definition of a taggable object.

Returns one of the following:
- `false` - the effect is explicitly disabled
- `true` - the effect is enabled with no filter
- `table` - the effect is enabled with the given filter settings
- `nil` - the effect is not set on this object

### Sound
Sounds represent a piece of audio that you can play back multiple times simultaneously with different pitches and volumes. Inherits from Taggable.

#### Properties

##### `Sound.loop (boolean)`
Whether the sound should be repeated until stopped.

#### Functions

##### `local instance = Sound:play(options)`
Plays a sound.

Parameters:
- `options` (`table`) (optional) - options to apply to this instance of the sound. The options table can have the following values:
  - `volume` (`number`) (optional, defaults to `1`) - the volume of the instance, from 0 to 1
  - `tags` (`table`) (optional) - a list of tags to apply to the instance
  - `effects` (`table`) (optional) - the effects to apply to the instance. Each key should be the name of the effect, and each value should be one of the following:
    - `true` - enables the effect without a filter
    - `table` - enables the effect with the filter settings specified in the table
    - `false` - explicitly disables the effect, even if the effect would normally be inherited from the parent sound or a tag
  - `loop` (`boolean`) (optional) - whether the instance of the sound should be repeated until stopped
  - `pitch` (`number`) (optional, defaults to `1`) - the pitch to play the sound at - 2 would be twice as fast and one octave up, .5 would be half speed and one octave down
  - `seek` (`number`) (optional) - the position to start the sound at in seconds
  - `fadeDuration` (`number`) (optional) - the length of time to use to fade in the sound from silence

Returns:
- `instance` (`Instance`) - the new instance of the sound

##### `Sound:pause(fadeDuration)`
Pauses all instances of this sound.

Parameters:
- `fadeDuration` (`number`) (optional) - the length of time to use to fade the sound to silence before pausing it

##### `Sound:resume(fadeDuration)`
Resumes all of the paused instances of this sound.

Parameters:
- `fadeDuration` (`number`) (optional) - the length of time to use to fade the sound from silence

##### `Sound:stop(fadeDuration)`
Stops all instances of this sound.

Parameters:
- `fadeDuration` (`number`) (optional) - the length of time to use to fade the sound to silence before stopping it

### Instance
An instance is a single occurrence of a sound. Inherits from Taggable.

#### Properties

##### `Instance.loop (boolean)`
Whether this instance of a sound should be repeated until stopped.

##### `Instance.pitch (number)`
The pitch of the instance.

#### Functions

##### `local stopped = Instance:isStopped()`
Returns if the instance is stopped, either because it reached the end of the sound or it was manually stopped. Note that stopped instances may be reused later.

##### `Instance:pause(fadeDuration)`
Pauses the instance.

Parameters:
- `fadeDuration` (`number`) (optional) - the length of time to use to fade the sound to silence before pausing it

##### `Instance:resume(fadeDuration)`
Resumes a paused instance.

Parameters:
- `fadeDuration` (`number`) (optional) - the length of time to use to fade the sound from silence

##### `Instance:stop(fadeDuration)`
Stops the instance.

Parameters:
- `fadeDuration` (`number`) (optional) - the length of time to use to fade the sound to silence before stopping it

### Tag
A tag represents a category of sounds. You can apply it to sounds to control the volume and effect settings of multiple sounds at once.

#### Functions

##### `Tag:pause(fadeDuration)`
Pauses all of the sounds tagged with this tag.

Parameters:
- `fadeDuration` (`number`) (optional) - the length of time to use to fade the sound to silence before pausing it

##### `Tag:resume(fadeDuration)`
Resumes all of the paused sounds tagged with this tag.

Parameters:
- `fadeDuration` (`number`) (optional) - the length of time to use to fade the sound from silence

##### `Tag:stop(fadeDuration)`
Stops all of the sounds tagged with this tag.

Parameters:
- `fadeDuration` (`number`) (optional) - the length of time to use to fade the sound to silence before stopping it

## Contributing

This library is still in early development, so feel free to report bugs, make pull requests, or just make suggestions about the code or design of the library. To run the test project, run `lovec .` in the ripple base directory.
