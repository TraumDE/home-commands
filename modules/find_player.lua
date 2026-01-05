local findPlayer = {}

function findPlayer.findPlayer(username, playersData) 
    local playerData = nil

    for _index, data in ipairs(playersData) do 
        if data[1] == username then 
            playerData = data
            break
        end
    end

    return playerData
end

return findPlayer