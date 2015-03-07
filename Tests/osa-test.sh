#!/usr/bin/env osascript

tell application "AnyBar.app"
    launch
    activate
end tell

delay 3

tell application "AnyBar.app"
    set image name to "green"
    display notification image name as Unicode text
end tell

delay 3

tell application "AnyBar.app"
    quit
end tell

