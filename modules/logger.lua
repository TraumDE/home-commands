local daveLogger = (function ()
    if pack.is_installed("dave_logger") then
        return require("dave_logger:logger")("home_commands")
    end
end)()

local logger = {}

function logger.log(message, enabled, ...)
    if daveLogger and enabled then
        daveLogger:info(message, ...)
    end
end


return logger