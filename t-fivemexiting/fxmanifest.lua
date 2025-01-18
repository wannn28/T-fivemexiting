fx_version 'cerulean'
lua54 'yes'
game 'gta5'
name 'P50-Exit'
author 'Team Project5.0'
version '1.0.0'
description 'Project5.0 Exit Fivem'

work_with 'ESX/QB latest version'

shared_script {
	'@ox_lib/init.lua',
	'config.lua',
}

client_script {
  'client/*.lua',
}
server_script {
  '@oxmysql/lib/MySQL.lua',
  'server/*.lua',
}

