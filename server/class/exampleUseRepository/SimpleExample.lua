--[[
--- Created: 17/07/2022 10:04
--- Author: Absolute
--Made with ❤
-------
-- Simple singleton in Qx => a singleton is a object automatically instanciate when import the class when you import the class the object is always the same.
--]]

QX.export("SimpleService", function(cls)
    ---@class SimpleService : QX.Object
    local class = cls;

    ---@type SimpleEntity
    local SimpleEntity = QX.import("SimpleEntity"); --- Import the SimpleEntity class the importation is import to instantiate the class.

    ---Important to use the repository system => import the Repository class
    ---@type Repository
    local Repository = QX.import("Repository");

    function class:constructor(test)
        Console:info("Value passed to the constructor: " .. test);
        ---@type Repository
        self.repository = Repository:new({
            table = "simple_repository", --The table name in the database this table will be created automatically
            class = "SimpleEntity", --The class name of the entity the orm will instanciate object when reading from the database
            columns = {
                test            = { type = "varchar(255)" }, --type => SQL type, here varchar(255) is a string with a max length of 255 characters
                myNumber        = { type = "int(11)" }, --type => SQL type, here int(11) is an integer with a max length of 11 characters
                data            = { type = "longtext", output = "Object" },  --type => SQL type, here longtext is a long text,
                                                                             --the orm auto json.encode/json.decode this column
            },
        });
    end

    return class;
end)