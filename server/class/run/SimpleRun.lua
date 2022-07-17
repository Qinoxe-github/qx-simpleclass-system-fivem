--[[
--- Created: 17/07/2022 09:45
--  Author: Absolute
--Made with ❤
-- Simple example to run the QX context.
--]]

QX.run(function()
    -- Import the SimpleEntity class the importation is import to instantiate the class.
    ---@type SimpleEntity
    local SimpleEntity = QX.import("SimpleEntity");

    ---@type SimpleService
    local SimpleService = QX.import("SimpleService");


    Console:info("Hello World! From Qx context in the server side!")

    -- Create a new instance of the SimpleEntity class
    local myInstance = SimpleEntity:new();

    -- use simple console system for logging
    Console:info(myInstance.test)

    -- Set myInstance.test to "test2"
    myInstance.test = "Toto";

    -- print value of myInstance.test
    Console:info(myInstance.test)

    Console:info("Use the repository system to save the instance in the database")

    local simpleExample = SimpleService:new("Tewttttt"); -- Create a new instance of the SimpleExample class and pass some argument to the constructor of the object

    simpleExample.repository:deleteAll(); -- Delete all the data in the database

    simpleExample.repository:create(myInstance); -- Save the instance in the database with the repository system
end)