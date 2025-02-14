local USERPROFILE = os.getenv("USERPROFILE"):gsub("\\", "/") .. "/Desktop/PokemonYellow_BadAppleTAS/src/TASproject/"
local input_file = io.open(USERPROFILE .. "input.txt", 'r')
local inputprogram_file = io.open(USERPROFILE .. "inputprogram.txt", 'r')
local scene = 0; -- 0: セットアップ, 1: プログラム入力

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

local input_data = {}
for line in input_file:lines() do
    table.insert(input_data, line)
end

local inputprogram_data = {}
for line in inputprogram_file:lines() do
    table.insert(inputprogram_data, line)
end

on_input = function(subframe)
    local frame = movie.currentframe()
    if scene == 0 then -- セットアップ
        line_input(input_data[frame])
        if memory.readbyte(0x1000) == 1 then -- サブフレーム実行のフラグをチェック
            scene = 1
        end
    end
    
    if scene == 1 then -- プログラム入力
        -- if subframe == false then
        --     return
        -- end
        local inputprogram_startaddr = 0x19B2
        local inputprogram_cnt = memory.readbyte(0x1001) + 1
        local byte = input2byte(inputprogram_data[inputprogram_cnt])
        line_input(inputprogram_data[inputprogram_cnt])
        print("byte: " .. byte .. ", memory:" .. memory.readbyte(inputprogram_startaddr + inputprogram_cnt - 1))
    end
    print("frame: " .. frame  .. ", scene: " .. scene)

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

-- 入力文字列を数値にもどす
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