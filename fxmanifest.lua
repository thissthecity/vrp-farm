fx_version 'adamant'
game 'gta5'

version '1.0.0'
author 'GFive'
description 'GFive VRP Farm'

client_scripts {
	"@vrp/lib/utils.lua",
	"client/**/*.lua"
}

server_scripts {
	"@vrp/lib/utils.lua",
	"server/**/*.lua"
}

files {
    "nui/**"
}

ui_page {
    "nui/index.html"
}
