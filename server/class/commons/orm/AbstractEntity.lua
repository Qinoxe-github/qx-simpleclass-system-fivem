---
--- Created by Absolute.
---

QX.export("AbstractEntity", function(cls)
    ---@class AbstractEntity : QX.Object
    local class = cls;

    function class:constructor()
        self.id = QX.uuid();
    end

    return class;
end)