-- Set the FX version and game type
fx_version 'cerulean'
game 'gta5'

-- Resource metadata
author 'Armour <armourgroup>'
description 'ArmourAnimations'
version '1.0.0'

ox_lib 'locale'

-- Define client-side scripts
client_scripts {
	'@qbx_core/modules/playerdata.lua',
	'client/*.lua',
}

-- Define server-side scripts
server_scripts {
	'server/*.lua',
}

-- Define scripts shared between client and server
shared_scripts {
	'@ox_lib/init.lua',
	'@qbx_core/modules/lib.lua',
}

-- Define files that should be included in the resource
files {
	'locales/*.json',
	'config/client.lua',
	'config/shared.lua',
}

-- Define files ignore to escrow
escrow_ignore {
	'config/*',
}

-- Set Global
lua54 'yes'
