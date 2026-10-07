# ubuntu-light-themes-gtk4

A faithful port of the Ambiance and Radiance themes to GTK4

## About

The goals of this project are to:

- Restore and port the original Ambiance and Radiance GTK3.20 themes used in Ubuntu until 19.10 to work nicely with modern GTK4 and Libadwaita applications
- Refactor and future-proof the codebase, such that it is easy-to-maintain (especially with Sass) and will be compatible with GTK5 or easy to be made so
- In doing all of this, remain faithful to how these themes appeared in GTK3; as far as is possible, refactors and modifications may only be made where the compiled CSS renders identically. This includes:
  - Not trying to guess the original intent of any style, except where it is unambiguous
  - Maintaining spurious styles which, going off the rest of the code, are likely unintentional, including tiny differences between Ambiance and Radiance, except where these are clearly bugs, typos or misspellings
  - In situations when GTK4 has changed how styles are rendered, doing our best to recreate the original rendered output, however hacky the solution
- The above inevitably implies remaining faithful to the code, as it's the source of said appearance. Hence, clearly document deviations from the original code
- Eventually create a completely dark mode of Ambiance

It is also very important to make clear that remaining faithful to the aesthetic and design of Ambiance and Radiance takes precedence over being beholden to the [Please don't theme our apps](https://stopthemingmy.app/) movement, with which we are incompatible in essence. This project strives to ensure apps remain comfortably usable and not broken by the themes, and to that end, we copy styles from Libadwaita when they don't conflict with those of the original themes so as to maximise compatibility and minimise likelihood of breakage. For instance, Libadwaita's colour palette is ripped verbatim from their stylesheet, as is some of `AdwStatusPage`'s styling.

However, by the very nature of this project, we are going to be making our own assumptions and prescriptions as to how apps should look, which necessarily means overriding app developer intent when it conflicts with Ambiance/Radiance aesthetics (e.g. we ignore `.circular`, `.rounded` and `.pill` style classes on buttons, because it has been judged that Ambiances's/Radiance's mostly rectangular borders are a cornerstone of the aesthetic). Because of this, there will inevitably be visual bugs in apps whose assumptions are incompatible with our prescriptions; this is an inherent consequence of third-party designs being applied to applications which do not take them into account during implementation.

Therefore, by installing and using these themes, **you understand and accept this risk, and agree to confirm that any visual bugs you encounter in GTK4/Libadwaita apps are not present on the default theme before inundating app developers with bug reports.** Otherwise, report it to this project - in GTK land, any issue that only occurs when a third-party theme is in use is a bug in the theme.

## Compiling and installing

To compile this theme, you will need to have Dart Sass installed along with a JavaScript package manager such as npm or Bun. You will probably need to have at least Dart Sass 1.95.0, as this project uses [the new `if()` syntax](https://sass-lang.com/documentation/breaking-changes/if-function/), though I've not tested versions that old.

> [!TIP]
> If you don't know where to start, refer to the _Command Line_ section at https://sass-lang.com/install/

Once you have ensured Sass is installed, run the included script to compile the themes and install them:

```sh
$ ./install.sh
```

By default, this will install the themes to `$XDG_DATA_HOME/themes`. If you wish to install them to `/usr/share/themes` or some other path, you may pass it with the `-d`/`--destination` option. Note that this script assumes write-access, so you'll probably need to run it with `sudo` for that to work (though I have not tested this so YMMV.)

Unfortunately, Libadwaita hates its users (😉) and doesn't want them to style its apps, so it's insufficient to simply set the GTK theme the standard way with some species of `gsettings set org.gnome.desktop.interface gtk-theme <theme>` (such as through KDE's System Settings) as Libadwaita will simply ignore it and apply its own stylesheet anyway.

To circumvent this, you must also set the environment variable `GTK_THEME` to either `Ambiance` or `Radiance` after installing. You can do this most easily by appending to `/etc/environment`:

```sh
echo "\nGTK_THEME=Ambiance" | sudo tee -a /etc/environment
```

...but you're free to go about this in whichever other way you set your envvars (e.g. in your Hyprland config if you're that kind of person).

## Known issues

Sometimes, you might encounter an issue wherein no GTK4 application can properly launch when you've installed the theme using the above steps. [This is because of a GTK4 bug.](https://discourse.gnome.org/t/gtk4-gets-stuck-in-infinite-loop-when-gtk-theme-and-gtk-application-prefer-dark-theme-are-set-to-certain-values/38639) For some reason, the specific combination of `GTK_THEME` being set to a theme that's identical to what's in the user configuration along with `~/.config/gtk-4.0/settings.ini` containing a value for `gtk-application-prefer-dark-theme` makes GTK go buggy-bonkers and enter some infinite loop. Deleting this line (or, more simply, this file) should fix this issue.

## Copyright

This project incorporates or adapts material from the following projects:

- Ubuntu Ambiance and Radiance themes
  Copyright © Canonical Ltd. and contributors
  Licenced under GPL-3.0

- Handy
  Copyright © The GNOME Project contributors
  Licenced under LGPL-2.1-or-later

- GTK
  Copyright © The GNOME Project contributors
  Licenced under LGPL-2.1-or-later

- Libadwaita
  Copyright © The GNOME Project contributors
  Licenced under LGPL-2.1-or-later

Unless otherwise noted, modifications and new code in this repository are
Copyright © 2026 Michael Fohqul
and licenced under GPL-3.0.

This project has also made use of AI models (namely Claude and ChatGPT) in its development. This is only done as help with research, debugging or as a general learning aid; code is always manually written by hand, with the intent and knowledge of the author as to its purpose and function.
