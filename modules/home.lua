local settings = require("home_commands:read_settings")
local findPlayer = require("home_commands:find_player")
local logger = require("home_commands:logger")

local M = _G["$Multiplayer"]
local API = (function()
    if M and M.side == "server" then 
        return require(string.format("%s:api/%s/api", M.pack_id, M.api_references.Neutron[2]) )[M.side]
    end
end)()
local serverConsole = (function()
    if API then 
        return API.console 
    end
end)()

local SAVES_PATH = pack.data_file('home_commands', settings.SAVES_PATH) 
local SERVER_COMMAND = string.format("%s: arg=[string] -> %s", settings.HOME_COMMAND, settings.HOME_DESCRIPTION) 

local home = {}

local function mainClient (_args, _kwargs)
    if not file.exists(SAVES_PATH) then
        console.chat(string.format("%s %s", settings.COLORS[settings.ERROR_COLOR], settings.ERROR_MESSAGE))
        return
    end 

    local saves = json.parse(file.read(SAVES_PATH))
    
    local playerId = saves[1][1]
    local posX, posY, posZ = saves[1][2], saves[1][3], saves[1][4]
    
    logger.log("Player: %s Teleported to home point: X:%f Y:%f Z:%f", settings.HOME_LOGS, playerId, posX, posY, posZ)

    player.set_pos(playerId, posX, posY, posZ)
end

local function mainServer (args, client)
    if not file.exists(SAVES_PATH) then 
        serverConsole.tell(string.format("%s %s", settings.COLORS[settings.ERROR_COLOR], settings.ERROR_MESSAGE), client)
        return
    end 

    local arg = args.arg
    local saves = json.parse(file.read(SAVES_PATH))
    local account = client.account
    local identity = account.identity

    if arg and table.has(settings.ADMIN_ROLES, account.role) then

        if arg == "list" then
            for _index, save in ipairs(saves) do
                serverConsole.tell(string.format("%s", table.tostring(save)), client)
            end
            logger.log("Admin: %s Viewed the list of player houses", settings.HOME_ADMIN_LOGS, identity)
        else
            local targetSave = findPlayer.findPlayer(arg, saves)
            if not targetSave then
                serverConsole.tell(string.format("%s%s", settings.COLORS[settings.ERROR_COLOR], settings.ERROR_MESSAGE), client)
                return
            end
            serverConsole.tell(string.format("%s", table.tostring(targetSave)), client)
            logger.log("Admin: %s Viewed Player: %s Home point ", settings.HOME_ADMIN_LOGS, identity, targetSave[1])
        end

        return
    end

    local saveExists = findPlayer.findPlayer(identity, saves)

    if not saveExists then 
        serverConsole.tell(string.format("%s%s", settings.COLORS[settings.ERROR_COLOR], settings.ERROR_MESSAGE), client)
        return 
    end

    player.set_pos(client.player.pid, saveExists[2], saveExists[3], saveExists[4])

    logger.log("Player: %s Teleported to home point: X:%f Y:%f Z:%f", settings.HOME_LOGS, identity, saveExists[2], saveExists[3], saveExists[4])
end

local function initClient()
    console.add_command(
        settings.HOME_COMMAND,
        settings.HOME_DESCRIPTION,
        mainClient,
        settings.IS_HOME_CHEAT
    )
end

local function initServer()
    serverConsole.set_command(
        SERVER_COMMAND, 
        {}, 
        mainServer, 
        settings.CAN_USE_HOME_UNAUTHORIZED
    )
end

function home.init() 
    if API then
        initServer()
    else
        initClient()
    end
end

return home