# Firefox Config

This is my firefox config.
It contains `userChrome.css`, a userscript loader, and some scripts and more.

## Userscript Loader

I have built (or rather "borrowed," see Credits) a bare-bones userscript loader that is defined in the [`loader.mjs`](profile/chrome/loader.mjs) file.
This looks inside the user chrome directory and loads the scripts specified in the `scripts` array into every new window.
The loader itself uses the `Injector` defined in [`utils.mjs`](profile/chrome/js/utils.mjs).

### Installation

The contents of `autoconfig` go into `/usr/lib64/firefox`, or wherever firefox is installed, and the contents of `profile` go into your profile folder.

### Credits

I took inspiration (read: stole a lot of this) from [MrOtherGuy](https://github.com/MrOtherGuy/fx-autoconfig) and then gutted his solution to the bare bones.
Therefore, credit definitely, and copyright probably belongs to him.

Use this according to [the licence](https://github.com/MrOtherGuy/fx-autoconfig/blob/master/LICENSE) he's using for the project I took his code from (Mozilla Public License 2.0).

Is there any other way to do anything cool with Firefox than steal stuff from MrOtherGuy though? I don't think so.
