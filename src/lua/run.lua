local input_filepath = os.getenv("USERPROFILE"):gsub("\\", "/") .. "/Desktop/PokemonYellow_BadAppleTAS/src/TASproject/input.txt"
local input_file = io.open(input_filepath, 'r')

if input_file == nil then
    print("Error: input file not found")
    local handle = io.popen("cd")  -- Windowsでは"cd", Linux/macOSでは"pwd"
    local current_dir = handle:read("*l")
    handle:close()
    print("Not fond file path: " .. input_filepath)
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

on_input = function(subframe)
    local frame = movie.currentframe()
    line_input(input_data[frame + 1])
end

function line_input(line)
    for i = 1, #line do
        local char = string.sub(line, i, i)
        local button = input_dict[char]
        if button == -1 then
            input.reset()
            return
        end
        if button ~= nil then
            input.set(0, button, 1)
        end
    end 
end