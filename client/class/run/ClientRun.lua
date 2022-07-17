--[[
--- Created: 17/07/2022 10:31
--  Author: Absolute
--]]

QX.run(function()
    ---@type SimpleClass
    local SimpleClass = QX.import("SimpleClass");

    local simpleClassInstance = SimpleClass:new();

    Console:info("Hello World! From Qx context!");
end)