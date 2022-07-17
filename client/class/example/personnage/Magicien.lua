--[[
--- Created: 17/07/2022 15:50
--- Author: Absolute
--Made with ❤
-------
-------
--Copyright (c) 2022 MFA Concept, All Rights Reserved.
--This file is part of MFA Concept project.
--Unauthorized using, copying, modifying and/or distributing of this file
--via any medium is strictly prohibited. This code is confidential.
-------
--]]

QX.extends("Magicien", "Personnage", function(cls)
    ---@class Magicien : Personnage
    local class = cls;

    function class:constructor(pseudo)
        self:super(pseudo);
    end

    function class:attaquer()
        print("Attaque de " .. self.pseudo.." en tant que magicien");
    end

    return class;
end)