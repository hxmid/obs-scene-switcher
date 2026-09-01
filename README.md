# obs-scene-switcher
automatically switches between the "gaming" and "normal" scenes based on the currently active application

## what
currently just looks at the currently focused application's path - i.e. where the .exe file is located.

if it's in one of the following directories
- `d:\games\**`
- `e:\games\**`

it will switch the current scene from `normal` to `gaming`

that's it. it's pretty primitive but it works well for me

in theory it's possible to add exceptions following that logic, but i don't need any at the moment

## how
leverages [redraskal](https://github.com/redraskal)'s [detect_fullscreen.dll](https://github.com/redraskal/detect_fullscreen), specifically the `get_fullscreen_window_executable_path` exported function
