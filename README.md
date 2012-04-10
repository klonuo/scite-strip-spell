This script can be used as a wrapper to custom spell-checker with Ispell compatible mode that operates on arbitrary selection (is there is any) or whole document. It should be placed in SciTE Lua start-up script

Can be evoked from .properties as:

```
command.name.9.*=Spell-check
command.mode.9.*=subsystem:lua
command.9.*=spell
```

<a href="http://i.imgur.com/mgUom.png">![screen-shot](http://i.imgur.com/mgUoms.png "shell action")</a>

Words can be added to dictionary if there is appropriate file in user's home folder, which should be changed to desired language. Similarly desired
language can be set by adding dictionary to aspell io.popen command line.

`sed` intervention is because there is bug in Aspell Ispell mode, and it does no harm otherwise. I could've used Hunspell, but perhaps there is yet
other bug which makes it unnaturally slow in Ispell mode.

*Known issue*: if user presses Escape on strip dialog, indicators are not cleaned - cleaning is done by Cancel button or if traversing ends
