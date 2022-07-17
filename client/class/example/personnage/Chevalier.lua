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

QX.extends("Chevalier", "Personnage", function(cls)
    ---@class Chevalier : Personnage
    local class = cls;

    function class:constructor(pseudo)
        self:super(pseudo);
        self.statsDefense = 50;
    end

    function class:bloquerAttaque()
        print("Bloque l'attaque de " .. self.pseudo.." en tant que chevalier");
    end

    return class;
end)