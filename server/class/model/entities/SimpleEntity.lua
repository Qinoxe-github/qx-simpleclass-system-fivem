--[[
--- Created: 17/07/2022 09:41
--- Author: Absolute
--- Create a entity to use the repository system, this entity can be used in the repository system.
--]]
QX.extends("SimpleEntity","AbstractEntity", function(cls)
    ---@class SimpleEntity : AbstractEntity  | This annotation is important for the class system to know that this class is a child of AbstractEntity
    local class = cls;

    function class:constructor()
        self:super(); -- This call the constructor of the parent class (AbstractEntity) and set the id.
        self.test = "";
        self.myNumber = 0;
        self.data = {};
    end

    return class;
end)