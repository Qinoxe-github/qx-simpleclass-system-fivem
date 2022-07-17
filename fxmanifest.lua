fx_version 'cerulean'
games { 'gta5', 'rdr3' }

author 'Absolute'
description 'qx class system'
version '0.0.1'

client_scripts {
    "client/class/**",      -- | this is for the class system you dont need to touch this
}

server_script {
    "server/sql/build.js",  -- |
    "server/define.lua",    -- | this 3 imports are for the database (oxmysql)
    "server/sql/MySQL.lua", -- |

    "server/class/**",      -- | this is for the class system you dont need to touch this
}

shared_scripts {
    "shared/Config.lua",     -- |
    "shared/core/Logs.lua",  -- | this 3 imports are required to use the class system and logs
    "shared/core/QX.lua",    -- |
    "shared/class/**",       -- | this is for the class system you dont need to touch this
}