local USERPROFILE = os.getenv("USERPROFILE"):gsub("\\", "/") .. "/Desktop/PokemonYellow_BadAppleTAS/src/TASproject/"
local input_file = io.open(USERPROFILE .. "input.txt", 'r') -- セットアップまでのボタン操作
local inputprogram_file = io.open(USERPROFILE .. "inputprogram.txt", 'r') -- 画像入力に使うプログラム
local inputmovie_file = io.open(USERPROFILE .. "movie.txt", 'r') -- 画像
local inputsound_file = io.open(USERPROFILE .. "sound.txt", 'r') -- 音楽

local scene = 0; -- 0: セットアップ, 1: プログラム入力, 2: グラフィック入力
local inputprogram_frame_cnt = 1 -- プログラムの何バイト目か
local movie_frame_cnt = -3 -- 何枚目の画像か
local sound_frame_cnt = -1 -- 何枚目の音か

if input_file == nil or inputprogram_file == nil then
    print("Error: input file not found")
    local handle = io.popen("cd")  -- Windowsでは"cd", Linux/macOSでは"pwd"
    local current_dir = handle:read("*l")
    handle:close()
    print("Not found file path")
    print("Current directory: " .. (current_dir or "Unknown"))

    return
end


local input_dict = {
    ["A"] = 0,
    ["B"] = 1,
    ["s"] = 2,
    ["S"] = 3,
    ["R"] = 4,
    ["L"] = 5,
    ["U"] = 6,
    ["D"] = 7,
    ["P"] = -1,
}

local input_dict_reverse = {}
for key, value in pairs(input_dict) do
    input_dict_reverse[value] = key
end

local input_data = {}
for line in input_file:lines() do
    table.insert(input_data, line)
end

-- local inputprogram_data = {}
-- for line in inputprogram_file:lines() do
--     table.insert(inputprogram_data, line)
-- end

-- local movie_data = {}
-- for line in inputmovie_file:lines() do
--     table.insert(movie_data, line)
-- end

on_input = function(subframe)
    local frame = movie.currentframe()
    -- print("frame: " .. frame  .. ", scene: " .. scene)
    if scene == 0 then -- セットアップ
        if memory.readbyte(0x1000) == 1 then -- サブフレーム実行のフラグをチェック
            scene = 1
        end

        line_input(input_data[frame])
    end
    
    if scene == 1 then -- プログラム入力
        if memory.readbyte(0x1000) == 2 then
            scene = 2
        end

        local send_data = get_inputprogram(inputprogram_frame_cnt)
        line_input(send_data)
        inputprogram_frame_cnt = inputprogram_frame_cnt + 1
        -- local inputprogram_startaddr = 0x19B2
        -- local inputprogram_cnt = memory.readbyte(0x1001) + 1
        -- local byte = input2byte(inputprogram_data[inputprogram_cnt])
        -- line_input(inputprogram_data[inputprogram_cnt])
    end

    if scene == 2 then -- グラフィック入力
        if memory.readbyte(0x1000) == 3 then
            scene = 3
        end
        local write_mode = memory.readbyte(0x1003)

        if write_mode == 0 then
            local send_data = get_movie(movie_frame_cnt)
            line_input(send_data)
            movie_frame_cnt = movie_frame_cnt + 1
        else 
            local send_data = get_sound(sound_frame_cnt)
            line_input(send_data)
            sound_frame_cnt = sound_frame_cnt + 1
        end
    end

    if scene == 3 then -- 終了
        local send_data = "B"
        if frame % 2 == 0 then
            send_data = send_data .. "A"
        end
        line_input(send_data)
    end

end

-- 入力文字列通りに入力する
function line_input(line)
    local input_flg = {["A"] = false, ["B"] = false, ["s"] = false, ["S"] = false, ["R"] = false, ["L"] = false, ["U"] = false, ["D"] = false}
    for i = 1, #line do
        local char = string.sub(line, i, i)
        local button = input_dict[char]
        if button == -1 then
            input.reset()
            return
        end
        if button ~= nil then
            input_flg[char] = true
        end
    end 
    for key, value in pairs(input_flg) do
        if value then
            input.set(0, input_dict[key], 1)
        else
            input.set(0, input_dict[key], 0)
        end
    end
end

-- 入力文字列を数値に変換
function input2byte(line)
    local byte = 0
    for i = 1, #line do
        local char = string.sub(line, i, i)
        local button = input_dict[char]
        if button == -1 then
            return nil
        end
        if button ~= nil then
            byte = byte + bit.lshift(1, button)
        end
    end
    return byte
end

-- 数値を入力文字列に変換
function byte2input(byte)
    local input = ""
    for i = 0, 7 do
        if bit.band(byte, bit.lshift(1, i)) ~= 0 then
            input = input .. input_dict_reverse[i]
        end
    end
    return input
end

function get_inputprogram(frame)
    if frame < 1 then 
        return ""
    end
    return inputprogram_file:read()
end

-- 画像を取得
function get_movie(frame)
    if frame < 1 then 
        return ""
    end
    return inputmovie_file:read()
end

-- 音を取得
function get_sound(frame)
    if frame < 1 then 
        return ""
    end
    return inputsound_file:read()
end