local server_utils = {}

local LoadResourceFile = LoadResourceFile
local GetCurrentResourceName = GetCurrentResourceName

server_utils.isInterfaceCompiled = function()
    local fileCheck = LoadResourceFile(GetCurrentResourceName(), "dist/index.html")
    return fileCheck and true or false
end

return server_utils
