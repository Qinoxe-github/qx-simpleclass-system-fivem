--[[
--Created Date: Tuesday May 24th 2022
--Author: Old MFA team[JustGod,Absolute]
--Made with ❤
-------
--]]

---@param inputstr string
---@param sep string
local function split (inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t={}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
        table.insert(t, str)
    end
    return t
end

function __FILE__(lvl)
    local tb = split(debug.getinfo(lvl, 'S').source,"/");
    return tb[#tb];
end

local function __LINE__(lvl) return debug.getinfo(lvl, 'l').currentline end

function __FUNC__(lvl) return debug.getinfo(lvl, 'n').name end

local function printlinefilefunc()
    print("Line at "..__LINE__()..", FILE at "..__FILE__()..", in func: "..__FUNC__())
end

---@class Logs
local Logs = {}

---@return Logs
function Logs:new()
    local self = {}
    setmetatable(self, {__index = Logs})
    self.types = {
        ["INFO"] = "[^5INFO^7]",
        ["WARNING"] = "[^9WARNING^7]",
        ["DEBUG"] = "[^1DEBUG^7]",
        ["MSG"] = "[^2MESSAGE^7]",
        ["ERROR"] = "[^6ERROR^7]",
        ["LOG"] = "[^2LOG^7]"
    }

    self.pattern = "%s : %s"

    return self
end

---@param msg string | table | number | boolean
---@param logType string
---@return string
function Logs:send(msg, logType, ...)
    local args = {...} or {""}
    if #args == 0 then args = ""
    else args  = tostring(json.encode(table.unpack(args)))
    end
    if msg == nil then return self:error("No data found") end
    if type(msg) == "table" then
        msg = tostring(json.encode(msg)) .. "^3"
    elseif type(msg) == "string" or type(msg) == "number" then
        msg = msg .. "^3"
    elseif type(msg) == "boolean" then
        msg = "Bool: ^1" .. tostring(msg) .. "^3"
    elseif type(msg) == "function" then
        msg = tostring(msg) .. "^3"
    else
        msg = msg .. "^3"
    end
    return print(("^7[^9%s^7] %s ^3%s"):format(string.upper(GetCurrentResourceName()) ,self.types[logType], msg), args,"^0")
end

---@param msg any
---@return string
function Logs:info(msg, ...)
    return self:send(msg, "INFO", ...)
end

---@param msg any
---@return string
function Logs:warn(msg, ...)
    return self:send(msg, "WARNING", ...)
end

function Logs:debugObject(msg)
    TriggerEvent("mdebug",msg);
end

---@param msg any
---@return string
function Logs:debug(msg, ...)
    if not Config.debug then return end
    return self:send(msg, "DEBUG", ...)
end

---@param msg any
---@return string
function Logs:msg(msg, trace, ...)
    return self:send(msg, "MSG", ...)
end

---@param msg any
---@return string
function Logs:log(msg, ...)
    msg = ("File : ^4%s ^3Line : ^4%s ^3%s"):format(__FILE__(3), __LINE__(3), msg)
    return self:send(msg, "LOG", ...)
end

---@param msg any
---@return string
function Logs:error(msg, ...)
    msg = ("File : ^4%s ^3Line : ^4%s ^1%s"):format(__FILE__(3), __LINE__(3), msg)
    return self:send(msg, "ERROR", ...)
end

function Logs:debugLine(msg, ...)
    msg = ("File : ^4%s ^3Line : ^4%s ^1%s"):format(__FILE__(3), __LINE__(3), msg)
    return self:send(msg, "DEBUG", ...)
end

---@param msg any
---@return string
function Logs:classLoaded(msg, ...)
    msg = ("^4%s ^3loaded"):format(msg)
    return self:send(msg ,"INFO", ...)
end

---Set the pattern of the logger.
---@overload fun():void
---@param string string
function Logs:pattern(value)
    self.pattern = value;
end

Console = Logs:new()

RegisterNetEvent("log:debugLine", function(msg, ...)
    Console:debugLine(msg, ...)
end)

RegisterNetEvent("log:warning", function(msg, ...)
    Console:warn(msg, ...)
end)