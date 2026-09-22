fx_version 'cerulean'
game 'gta5'

author 'Furious'
description 'Furious resource'
version '0.1.0'

dependencies {
    'oxmysql',
    'spawnmanager',
    '/onesync'
}

shared_scripts {
    'config/*.lua',
    'shared/*.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',

    'server/common.lua',

    'server/classes/player.lua',

    'server/functions.lua',
    'server/main.lua',

    'server/modules/database.lua',
    'server/modules/variables.lua',
    'server/variables.lua',
    'server/modules/player.lua',
}

client_scripts {
    'client/main.lua',
    'client/variables'
}
