--[[
--Created Date: Tuesday May 24th 2022
--Author: Old MFA team[JustGod,Absolute]
--Made with ❤
--]]


local defaultTemplate = "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx"
local random = math.random

local function stringsplit(inputstr, sep)
	if sep == nil then
		sep = "%s"
	end

	local t={} ; i=1
	for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
		t[i] = str
		i = i + 1
	end

	return t
end

local function stringtoCharArray(str)
    local array = {}

    for i = 1, #str do
        array[i] = str:sub(i, i)
    end

    return array
end

local function stringToHexa(str)
    return string.lower(string.format("%X", str))
end

local function numberToHexa(nb)
    return stringToHexa(("%s"):format(nb))
end

--  =========================================================
--  NE PAS RETIRER
--  en Lua les premiers chiffre ne sont pas très très random,
--  ça permet de skiper les premiers chiffre pour améliorer
--  les valeurs aléatoire suivante
if IsDuplicityVersion() then
    math.randomseed(os.time())
end

math.random();math.random();math.random()
math.random();math.random();math.random()
math.random();math.random();math.random()
math.random();math.random();math.random()

--  =========================================================

QX.export("TemplateUUID", function(cls)
    ---@class TemplateUUID : QX.Object
    local TemplateUUID = cls;

    function TemplateUUID:constructor(template)
        self.template = stringsplit(template or defaultTemplate, "-")
        self.cursor = 0
    end

    function TemplateUUID:getCursor()
        return self.cursor
    end
    
    function TemplateUUID:resetCursor()
        self.cursor = 0
    end
    
    function TemplateUUID:getToken(idx)
        return self.template[idx]
    end
    
    function TemplateUUID:getTokenNumber()
        return #self.template
    end
    
    function TemplateUUID:getRemainingTokenNumber()
        return self:getTokenNumber() - self:getCursor()
    end
    
    function TemplateUUID:getNextToken()
        if self:getRemainingTokenNumber() > 0 then
            self.cursor = self.cursor + 1
            return self:getToken(self.cursor)
        else
            return nil
        end
    end
    
    function TemplateUUID:getTemplate()
        return table.concat(self.template, "-")
    end

    return TemplateUUID;
end)

QX.singleton("UUID", function(cls)
    ---@class UUID
    local UUID = cls;

    ---@type TemplateUUID
    local TemplateUUID = QX.import("TemplateUUID")

    function UUID:constructor()
    end

    function UUID:getTemplate()
        return self.template
    end
    
    function UUID:__call(pattern)
        return self:generate(pattern)
    end
    
    function UUID:generate(pattern)
        local template = TemplateUUID:new(pattern)
        return string.gsub(template:getTemplate(), '[xy]',
            function (c)
                local v = (c == 'x') and random(0, 0xf) or random(8, 0xb)
                return string.format('%x', v)
            end)
    end

    --- return a unique UUID using default pattern and replacing
    ---
    --- @return string
    ---
    function UUID:unique(pattern)
        local hexa = stringtoCharArray(numberToHexa(os.time(os.date("!*t"))))
        local template = TemplateUUID:new(pattern)
        local token = template:getNextToken()
        local final = nil
        local idx = 0
    
        while token do
            
            if template:getRemainingTokenNumber() == 0 then
                token = string.gsub(token, '[xy]',
                    function(char)
                        idx = idx + 1
                        if char == 'x' and hexa[idx] then
                            return hexa[idx]
                        elseif char == 'x' then
                            return string.format('%x', random(0, 0xf))
                        else
                            return string.format('%x', random(8, 0xb))
                        end
                    end)
            else
                token = string.gsub(token, '[xy]',
                    function (c)
                        local v = (c == 'x') and random(0, 0xf) or random(8, 0xb)
                        return string.format('%x', v)
                    end)
            end
            
            final = final and ("%s-%s"):format(final, token) or token
            token = template:getNextToken()
        end
    
        return final
    end

    return UUID;
end)