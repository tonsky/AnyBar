# AnyBar: OS X menubar status indicator

AnyBar is a small indicator for your menubar that does one simple thing: it displays color dot. What color means is up to you. When to change color is also up to you.

<img src="AnyBar/Resources/screenshot.png?raw=true" />

## Download

Version 0.1.2:

<a href="https://github.com/tonsky/AnyBar/releases/download/0.1.2/AnyBar.app.zip"><img src="AnyBar/Images.xcassets/AppIcon.appiconset/icon_128x128@2x.png?raw=true" style="width: 128px;" width=128/></a>

## Usage

AnyBar is controlled via UDP port. Send it a message and it will change a color:

```sh
echo -n "black" | nc -4u -w0 localhost 1738
```

Following “commands” change color:

- black
- blue
- cyan
- green
- orange
- purple
- red
- white
- yellow
- question
- exclamation

And one special command forces AnyBar to quit: `quit`

## Custom images

You can use your own images if you put them under `~/.AnyBar`. E.g. if you have `~/.AnyBar/square@2x.png` present, you can send `"square"` to 1738 and it will be displayed. Images should be 19×19px (or twice that for retina).

## Configuration

Default port for AnyBar is 1738, you can change it by providing `ANYBAR_PORT` environment variable (note `open -n`):

```sh
ANYBAR_PORT=1788 open -n ./AnyBar.app
```

## Changelog

### 0.1.2

- Dark mode support. In dark mode AnyBar will first check for `<image>_alt@2x.png` or `<image>_alt.png` image first, then falls back to `<image>.png`
- Support for Mavericks actually works

### 0.1.1

- Support for Mavericks (PR #2, thx [Oleg Kertanov](https://github.com/okertanov))
- Support for custom images via ~/.AnyBar (PR #1, thx [Paul Boschmann](https://github.com/pboschmann))

## License

Copyright © 2015 Nikita Prokopov

Licensed under Eclipse Public License (see [LICENSE](LICENSE)).

