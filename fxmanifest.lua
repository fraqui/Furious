fx_version 'cerulean'
game 'gta5'

lua54 'yes'

author 'Furious'
description 'Furious resource'
version '0.1.0'

client_scripts {
    'client/main.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',

    'server/classes/player.lua',

    'server/functions.lua',
    'server/main.lua',

    'server/modules/database.lua',
    'server/modules/player.lua',
}

shared_scripts {
    'config/*.lua',
    'shared/*.lua'
}
