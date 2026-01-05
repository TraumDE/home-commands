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

local SAVES_PATH = pack.data_file('home_commands', settings.SAVES_PATH) -- 
local CLIENT_COMMAND = string.format("%s obj:sel=$obj.id x:num=$pos.x y:num=$pos.y z:num=$pos.z", settings.SETHOME_COMMAND) 
local SERVER_COMMAND = string.format("%s: identity=[string], x=[number], y=[number], z=[number] -> %s", settings.SETHOME_COMMAND, settings.SETHOME_DESCRIPTION)

local setHome = {}

local function writeData(identity, posX, posY, posZ)
    logger.log("Player: %s Changed home point to: X:%f Y:%f Z:%f", settings.SETHOME_LOGS, identity, posX, posY, posZ)

    if not file.exists(SAVES_PATH) then 
        local dataToSave = {
            {identity, posX, posY, posZ}
        }
        local JsonData = json.tostring(dataToSave, settings.READABLE_JSON)

        file.write(SAVES_PATH, JsonData) 
        return
    end 

    local playersData = json.parse(file.read(SAVES_PATH))
    local playerExists = findPlayer.findPlayer(identity, playersData)
    local dataToSave = {identity, posX, posY, posZ}

    if playerExists then
        playerExists[2] = posX
        playerExists[3] = posY
        playerExists[4] = posZ
    else
        table.insert(playersData, dataToSave)
    end

    local JsonData = json.tostring(playersData, settings.READABLE_JSON)

    file.write(SAVES_PATH, JsonData)
end

local function mainClient (args, _kwargs)
    writeData(unpack(args))
    player.set_spawnpoint(unpack(args))
    console.chat(string.format("%s%s", settings.COLORS[settings.SUCCESS_COLOR], settings.SUCCESS_MESSAGE))
end



local function mainServer (args, client) 
    local targetIdentity, targetX, targetY, targetZ = args.identity, args.x, args.y, args.z
    local account = client.account
    local identity = account.identity
    local playerId = client.player.pid
    local posX, posY, posZ = player.get_pos(playerId)

    if targetIdentity and table.has(settings.ADMIN_ROLES, account.role) then
        if not targetX and not targetY and not targetZ then
            writeData(targetIdentity, posX, posY, posZ)
            serverConsole.tell(string.format("%sHouse changed for other player", settings.COLORS[settings.SUCCESS_COLOR]),client)
            logger.log("Admin: %s Changed home point for Player: %s To: X:%f Y:%f Z:%f", settings.SETHOME_ADMIN_LOGS, identity, targetIdentity, posX, posY, posZ)
            return
        end
        
        if not targetX or not targetY or not targetZ then
            serverConsole.tell(string.format("%sArgs specified incorrectly", settings.COLORS[settings.ERROR_COLOR]),client)
            return
        end 

        writeData(targetIdentity, targetX, targetY, targetZ)
        serverConsole.tell(string.format("%sHouse changed for other player", settings.COLORS[settings.SUCCESS_COLOR]),client)
        logger.log("Admin: %s Changed home point for Player: %s To: X:%f Y:%f Z:%f", settings.SETHOME_ADMIN_LOGS, identity, targetIdentity, targetX, targetY, targetZ)

        return
    end

    writeData(identity, posX, posY, posZ)
    serverConsole.tell(string.format("%s%s", settings.COLORS[settings.SUCCESS_COLOR], settings.SUCCESS_MESSAGE), client)
end

local function initClient()
    console.add_command(
        CLIENT_COMMAND,
        settings.SETHOME_DESCRIPTION,
        mainClient,
        settings.IS_SETHOME_CHEAT
    )
end

local function initServer()
    serverConsole.set_command(
        SERVER_COMMAND, 
        {}, 
        mainServer, 
        settings.CAN_USE_SETHOME_UNAUTHORIZED
    )
end

function setHome.init() 
    if API then
        initServer()
    else
        initClient()
    end
end

return setHome