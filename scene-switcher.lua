obs = obslua

local NORMAL_SCENE = "normal"
local GAMING_SCENE = "gaming"
local POLL_INTERVAL = 500

local current_is_game = nil

function script_description()
    return [[automatically switches between the "gaming" and "normal" scenes based on the currently active application.

an application is considered a game if its executable is somewhere within D:\games\** or E:\games\**

Author: hxmid]]
end

function script_load()
    ffi = require("ffi")

    ffi.cdef[[
        int get_fullscreen_window_executable_path(char* buffer, int buffer_len);
    ]]

    -- from https://github.com/redraskal/detect_fullscreen
    detect_fullscreen = ffi.load(script_path() .. "detect_fullscreen.dll")

    obs.timer_add(check_active_window, POLL_INTERVAL)

    print("loaded")
end

function script_unload()
    obs.timer_remove(check_active_window)
    print("unloaded")
end

function check_active_window()
    local exe_path = get_executable_path()

    if exe_path == nil then
        return
    end

    local is_game = is_game_path(exe_path)

    if current_is_game == is_game then
        return
    end

    current_is_game = is_game

    if is_game then
        print("name detected: " .. exe_path)
        switch_scene(GAMING_SCENE)
    else
        print("non-game detected: " .. exe_path)
        switch_scene(NORMAL_SCENE)
    end
end

function get_executable_path()
    local path = ffi.new("char[?]", 260)

    local result = detect_fullscreen.get_fullscreen_window_executable_path(path, 260)

    if result ~= 0 then
        return nil
    end

    local exe_path = ffi.string(path)

    if #exe_path == 0 then
        return nil
    end

    return exe_path
end

function is_game_path(path)
    if path == nil then
        return false
    end

    path = string.lower(path)
    path = string.gsub(path, "/", "\\")

    if string.sub(path, 1, 9) == "d:\\games\\" then
        return true
    end

    if string.sub(path, 1, 9) == "e:\\games\\" then
        return true
    end

    return false
end

function switch_scene(scene_name)
    local source = obs.obs_get_source_by_name(scene_name)

    if source == nil then
        print("ERROR: scene '" .. scene_name .. "' does not exist")
        return false
    end

    obs.obs_frontend_set_current_scene(source)

    obs.obs_source_release(source)

    print("switched to scene: " .. scene_name)

    return true
end
