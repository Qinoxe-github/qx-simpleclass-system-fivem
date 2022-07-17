--[[
--- Created: 17/07/2022 10:31
--  Author: Absolute
--]]

QX.run(function()
    ---@type SimpleClass
    local SimpleClass = QX.import("SimpleClass");

    ---@type Chevalier
    local Chevalier = QX.import("Chevalier");
    ---@type Magicien
    local Magicien = QX.import("Magicien");

    local simpleClassInstance = SimpleClass:new();


    local chevalierInstance = Chevalier:new("Absolute");

    local magicienInstance = Magicien:new("Bape");

    chevalierInstance:attaquer()

    magicienInstance:attaquer();

    chevalierInstance:bloquerAttaque()


    Console:info("Hello World! From Qx context!");
end)