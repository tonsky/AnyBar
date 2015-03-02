# AnyBar: OS X menubar status indicator

AnyBar is a small indicator for your menubar that does one simple thing: it displays color dot. What color means is up to you. When to change color is also up to you.

<img src="screenshot.png" />

## Download

Download version 0.1.0 [from releases](https://github.com/tonsky/AnyBar/releases/download/0.1.0/AnyBar.app.zip)

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

And one special command forces AnyBar to quit: `quit`

Default port for AnyBar is 1738, you can change it by providing `ANYBAR_PORT` environment variable:

```sh
ANYBAR_PORT=1788 open ./AnyBar.app
```

or

```sh
ANYBAR_PORT=1788 ./AnyBar.app/Contents/MacOS/AnyBar &
```

(this way you can run multiple instances of AnyBar)