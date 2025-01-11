fx_version 'cerulean'
games { 'gta5' }

author 'Joker'
description 'camping'
version '1.0.0'
lua54 'yes'

client_script   'client/*.lua'

server_script 'server/*.lua'

shared_script  {
    'config.lua',
    '@ox_lib/init.lua'
}

