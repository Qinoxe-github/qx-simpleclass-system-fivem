--[[
--- Created: 17/07/2022 12:02
--- Author: Absolute
--]]

QX.extends("Class2", "SimpleClass", function(cls)
    ---@class Class2 : SimpleClass
    local class = cls;

    function class:constructor()
        self:super();
    end

    return class;
end)