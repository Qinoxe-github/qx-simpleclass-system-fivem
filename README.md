# QX Class system for fivem including simple lua ORM

## Features

- Import / Export Class
- Light Orm : Repository class
- Light logger using Console class not linked to Qx Context class

## Usage
1. Clone repository into your `resources/[local]` folder.
2. All classes created need to be in class folder like in example
## Example

Simple class declaration

```lua
QX.export("SimpleClass", function(cls)
    ---@class SimpleClass : QX.Object
    local class = cls;

    function class:constructor()

    end

    return class;
end)
```

Use Qx context

```lua
QX.run(function()
    Console.info("Hello World! From Qx context in the client side!")
end)
```

Import class and instantiate
```lua
QX.run(function()
    ---@type SimpleClass
    local SimpleClass = QX.import("SimpleClass");

    local simpleClassInstance = SimpleClass:new();

    Console:info("Hello World! From Qx context!");
end)
```

Extends system
```lua
QX.extends("Class2", "SimpleClass", function(cls)
    ---@class Class2 : SimpleClass
    local class = cls;

    function class:constructor()
        self:super();
    end

    return class;
end)
```

## Orm

With orm the SQL request will be automitzed by the Repository system / Only server side
Add this to your *server.cfg* is you want to use it

```lua
set mysql_mfa_load "mysql://root@localhost:3307/{MaDataBaseName}?waitForConnections=true&charset=utf8mb4"
```

Create entity for orm
```lua
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
```

Create simple service for using repository

```lua
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
```

Server side code example to use repository
```lua
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

    local simpleExample = SimpleExample:new("Tewttttt"); -- Create a new instance of the SimpleExample class and pass some argument to the constructor of the object

    simpleExample.repository:deleteAll(); -- Delete all the data in the database

    simpleExample.repository:create(myInstance); -- Save the instance in the database with the repository system
end)
```



