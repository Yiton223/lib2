local Utils = {}
Utils.__index = Utils

local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer 

-- Обновленная функция с поддержкой дней
function Utils:FormatTime(sec: number | string): string
    local seconds: number = tonumber(sec) or 0

    local days: number = math.floor(seconds / 86400)
    local hours: number = math.floor((seconds % 86400) / 3600)
    local minutes: number = math.floor((seconds % 3600) / 60)
    local secs: number = math.floor(seconds % 60)

    if days > 0 then
        return string.format("%d:%02d:%02d:%02d", days, hours, minutes, secs)
    else
        return string.format("%02d:%02d:%02d", hours, minutes, secs)
    end
end

local suffixes = {"", "K", "M", "B", "T", "Qa", "Qi", "Sx", "Sp", "Oc", "No", "Dc"}
function Utils:FormatNumber(n)
    n = tonumber(n) or 0
    if n < 1000 then return tostring(math.floor(n)) end
    local i = math.floor(math.log10(n) / 3) + 1
    return string.format("%.2f%s", n / (10 ^ ((i - 1) * 3)), suffixes[i] or "inf")
end

function Utils:GetFPS()
    return math.floor(1 / RunService.RenderStepped:Wait())
end

function Utils:GetMemory()
    return math.floor(Stats:GetTotalMemoryUsageMb()) .. " MB"
end

function Utils:GetPing()
    -- Добавлена проверка на наличие стата, чтобы избежать ошибок в Studio или при лагах
    local ping = 0
    pcall(function()
        ping = Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
    end)
    return math.floor(ping) .. " ms"
end

function Utils:GetDistance(pos1, pos2)
    if typeof(pos1) == "Instance" then
        if pos1:IsA("Player") and pos1.Character then
            pos1 = pos1.Character:GetPivot().Position
        elseif pos1:IsA("BasePart") or pos1:IsA("Model") then
            pos1 = pos1:GetPivot().Position
        end
    end
    
    if typeof(pos2) == "Instance" then
        if pos2:IsA("Player") and pos2.Character then
            pos2 = pos2.Character:GetPivot().Position
        elseif pos2:IsA("BasePart") or pos2:IsA("Model") then
            pos2 = pos2:GetPivot().Position
        end
    end

    if typeof(pos1) == "Vector3" and typeof(pos2) == "Vector3" then
        return (pos1 - pos2).Magnitude
    end
    return 0
end

function Utils:RandomColor()
    return Color3.fromRGB(math.random(0,255), math.random(0,255), math.random(0,255))
end

function Utils:dump(value, seen)
    seen = seen or {}
    local t = typeof(value)

    if t == "table" then
        if seen[value] then
            return "[CYCLE]"
        end
        seen[value] = true

        local out = {}
        for k, v in pairs(value) do
            local key = typeof(k) == "table" and "[TABLE_KEY]" or tostring(k)
            out[key] = Utils:dump(v, seen)
        end

        local mt = getmetatable(value)
        if mt then
            out.__metatable = Utils:dump(mt, seen)
        end

        return out

    elseif t == "Instance" then
        return {
            __type = "Instance",
            ClassName = value.ClassName,
            Name = value.Name,
            FullName = value:GetFullName()
        }

    elseif t == "function" then
        return "[FUNCTION]" -- Вызывать функцию внутри дампа небезопасно
    elseif t == "userdata" then
        return "[USERDATA]"
    elseif t == "thread" then
        return "[THREAD]"
    else
        return value
    end
end

function Utils:isArray(tbl)
    local count = 0
    for k in pairs(tbl) do
        if typeof(k) ~= "number" then
            return false
        end
        count += 1
    end
    return count == #tbl
end

function Utils:prettyEncode(value, level)
    level = level or 0
    local spacing = string.rep("  ", level)
    local t = typeof(value)

    if t == "table" then
        local array = Utils:isArray(value)
        local open = array and "[" or "{"
        local close = array and "]" or "}"
        local parts = {}

        for k, v in pairs(value) do
            local key = ""
            if not array then
                key = HttpService:JSONEncode(tostring(k)) .. ": "
            end

            table.insert(
                parts,
                spacing .. "  " .. key .. Utils:prettyEncode(v, level + 1)
            )
        end

        if #parts == 0 then
            return open .. close
        end

        return open .. "\n"
            .. table.concat(parts, ",\n")
            .. "\n" .. spacing .. close

    else
        return HttpService:JSONEncode(value)
    end
end

function Utils:DeepCopy(orig: table, pretty: boolean)
    if type(orig) ~= "table" then return orig end
    local dumped = Utils:dump(orig)

    if pretty then
        return Utils:prettyEncode(dumped)
    else
        return HttpService:JSONEncode(dumped)
    end
end

function Utils:IsOnGround(part)
    if not part or not part:IsA("BasePart") then return false end
    -- Использование RaycastParams (современный метод)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {part}
    
    local result = workspace:Raycast(part.Position, Vector3.new(0, -5, 0), params)
    return result ~= nil
end

return Utils