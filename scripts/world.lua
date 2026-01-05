local setHomeCommand = require("home_commands:set_home")
local homeCommand = require("home_commands:home")

function on_world_open()
    setHomeCommand:init()
    homeCommand:init()
end