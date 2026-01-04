fx_version("cerulean")
game("gta5")

name("minimal-hud")
author("MadCap <discord:https://discord.gg/dTNWpmPGyc>")
-- author("vipex <discord:vipex.v>")
version("2.42.8")
description ("Minimalistic FiveM HUD")
repository("https://github.com/ThatMadCap/minimal-hud")

shared_scripts({
    "@ox_lib/init.lua",
    "init.lua",
})

ui_page("dist/index.html")
-- ui_page("http://localhost:5173/")

files({
    "dist/index.html",
    "dist/assets/*.js",
    "dist/assets/*.css",
    "dist/**/*.woff2",
    "config/*.lua",
    "config/functions.lua",
    "modules/interface/client.lua",
    "modules/utility/shared/main.lua",
    "modules/seatbelt/client.lua",
    "modules/frameworks/**/*.lua",
    "modules/threads/client/**/*.lua",
})

lua54("yes")
use_experimental_fxv2_oal("yes")
nui_callback_strict_mode("true")
