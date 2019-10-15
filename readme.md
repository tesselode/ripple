# Ripple <!-- omit in toc -->

Ripple is an audio library for LÖVE that simplifies various aspects of audio handling, including tagging and playing multiple instances of a sound.

- [Installation](#installation)
- [API](#api)
  - [ripple](#ripple)
    - [Functions](#functions)
      - [`local sound = ripple.newSound(source, options)`](#local-sound--ripplenewsoundsource-options)
      - [`local tag = ripple.newTag(options)`](#local-tag--ripplenewtagoptions)
  - [Taggable](#taggable)
    - [Properties](#properties)
      - [`volume (number)`](#volume-number)
    - [Functions](#functions-1)
      - [`Taggable:tag(...)`](#taggabletag)
      - [`Taggable:untag(...)`](#taggableuntag)
      - [`Taggable:setEffect(name, effectSettings)`](#taggableseteffectname-effectsettings)
      - [`Taggable:removeEffect(name)`](#taggableremoveeffectname)
      - [`local effect = Taggable:getEffect(name)`](#local-effect--taggablegeteffectname)
  - [Sound](#sound)
    - [Properties](#properties-1)
      - [`loop (boolean)`](#loop-boolean)
    - [Functions](#functions-2)
      - [`local instance = Sound:play(options)`](#local-instance--soundplayoptions)
      - [`Sound:pause(fadeDuration)`](#soundpausefadeduration)
      - [`Sound:resume(fadeDuration)`](#soundresumefadeduration)
      - [`Sound:stop(fadeDuration)`](#soundstopfadeduration)
  - [Instance](#instance)
    - [Properties](#properties-2)
      - [`loop (boolean)`](#loop-boolean-1)
      - [`pitch (number)`](#pitch-number)
    - [Functions](#functions-3)
      - [`local stopped = Instance:isStopped()`](#local-stopped--instanceisstopped)
      - [`Instance:pause(fadeDuration)`](#instancepausefadeduration)
      - [`Instance:resume(fadeDuration)`](#instanceresumefadeduration)
      - [`Instance:stop(fadeDuration)`](#instancestopfadeduration)
  - [Tag](#tag)
    - [Functions](#functions-4)
      - [`Tag:pause(fadeDuration)`](#tagpausefadeduration)
      - [`Tag:resume(fadeDuration)`](#tagresumefadeduration)
      - [`Tag:stop(fadeDuration)`](#tagstopfadeduration)
  - [EffectSettings](#effectsettings)
- [Contributing](#contributing)

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
  - `effects` (`table`) (optional) - the effects to apply to the instance. Each key should be the name of the effect, and each value should be an [`EffectSettings`](#effect-settings) value
  - `loop` (`boolean`) (optional) - whether the sound should be repeated until stopped

Returns:
- `sound` ([`Sound`](#sound)) - the newly created sound

##### `local tag = ripple.newTag(options)`
Creates a new tag.

Parameters:
- `options` (`table`) (optional) - options to apply to the tag. The options table can have the following values:
  - `volume` (`number`) (optional, defaults to `1`) - the volume of the tag, from 0 to 1
  - `tags` (`table`) (optional) - a list of tags to apply to the tag
  - `effects` (`table`) (optional) - the effects to apply to the instance. Each key should be the name of the effect, and each value should be an [`EffectSettings`](#effect-settings) value

Returns:
- `tag` ([`Tag`](#tag)) - the newly created tag

### Taggable
This class is not something you create directly, but it does contain functions you can use on any taggable object: sounds, instances, and tags.

#### Properties

##### `volume (number)`
The volume of the taggable object from 0 to 1.

#### Functions

##### `Taggable:tag(...)`
Applies one or more tags to a taggable object.

Parameters:
- `...` ([`Tag`](#tag)) - the tags to apply

##### `Taggable:untag(...)`
Removes one or more tags from a taggable object.

Parameters:
- `...` ([`Tag`](#tag)) - the tags to remove

##### `Taggable:setEffect(name, effectSettings)`
Enables or disables an effect on a taggable object.

Parameters:
- `name` (`string`) - the effect to enable or disable
- `effectSettings` ([`EffectSettings`](#effect-settings)) - the settings to use for the effect

##### `Taggable:removeEffect(name)`
Unsets an effect on a taggable object.

Parameters:
- `name` (`string`) - the name of the effect to remove

##### `local effect = Taggable:getEffect(name)`
Returns the [EffectSettings](#effect-settings) for an effect on a taggable object.

### Sound
Sounds represent a piece of audio that you can play back multiple times simultaneously with different pitches and volumes. Inherits from [Taggable](#taggable).

#### Properties

##### `loop (boolean)`
Whether the sound should be repeated until stopped.

#### Functions

##### `local instance = Sound:play(options)`
Plays a sound.

Parameters:
- `options` (`table`) (optional) - options to apply to this instance of the sound. The options table can have the following values:
  - `volume` (`number`) (optional, defaults to `1`) - the volume of the instance, from 0 to 1
  - `tags` (`table`) (optional) - a list of tags to apply to the instance
  - `effects` (`table`) (optional) - the effects to apply to the instance. Each key should be the name of the effect, and each value should be an [`EffectSettings`](#effect-settings) value
  - `loop` (`boolean`) (optional) - whether the instance of the sound should be repeated until stopped
  - `pitch` (`number`) (optional, defaults to `1`) - the pitch to play the sound at - 2 would be twice as fast and one octave up, .5 would be half speed and one octave down
  - `seek` (`number`) (optional) - the position to start the sound at in seconds
  - `fadeDuration` (`number`) (optional) - the length of time to use to fade in the sound from silence

Returns:
- `instance` ([`Instance`](#instance)) - the new instance of the sound

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
An instance is a single occurrence of a sound. Inherits from [Taggable](#taggable).

#### Properties

##### `loop (boolean)`
Whether this instance of a sound should be repeated until stopped.

##### `pitch (number)`
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
A tag represents a category of sounds. You can apply it to sounds to control the volume and effect settings of multiple sounds at once. Inherits from [Taggable](#taggable).

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

### EffectSettings
Effect settings can either be:
- `true` - enables an effect with no filter
- `false` - explicitly disables an effect, even if normally an object would inherit an effect from a parent, like a tag or a sound
- `table` - enables an effect with a filter with the specified settings

## Contributing

This library is still in early development, so feel free to report bugs, make pull requests, or just make suggestions about the code or design of the library. To run the test project, run `lovec .` in the ripple base directory.
