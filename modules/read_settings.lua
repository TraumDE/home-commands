local importSetting = toml.parse(file.read("home_commands:config/settings.toml"))
local settings = {}

settings.HOME_DESCRIPTION = importSetting['general']['home-description']
settings.SETHOME_DESCRIPTION = importSetting['general']['sethome-description']
settings.HOME_COMMAND = importSetting['general']['home-command']
settings.SETHOME_COMMAND = importSetting['general']['sethome-command']
settings.SAVES_PATH = importSetting['general']['saves-path']
settings.ERROR_MESSAGE = importSetting['general']['error-message']
settings.SUCCESS_MESSAGE = importSetting['general']['success-message']
settings.ERROR_COLOR = importSetting['general']['error-color']
settings.SUCCESS_COLOR = importSetting['general']['success-color']
settings.READABLE_JSON = importSetting['general']['readable-json']
settings.IS_HOME_CHEAT = importSetting['client']['is-home-cheat']
settings.IS_SETHOME_CHEAT = importSetting['client']['is-sethome-cheat']
settings.CAN_USE_HOME_UNAUTHORIZED = importSetting['server']['can-use-home-unauthorized']
settings.CAN_USE_SETHOME_UNAUTHORIZED = importSetting['server']['can-use-sethome-unauthorized']
settings.COLORS = importSetting['colors']
settings.HOME_LOGS = importSetting['general']['home_logs']
settings.SETHOME_LOGS = importSetting['general']['sethome_logs']
settings.ADMIN_ROLES = importSetting['server']['admin-roles']
settings.HOME_ADMIN_LOGS = importSetting['server']['home-admin-logs']
settings.SETHOME_ADMIN_LOGS = importSetting['server']['sethome-admin-logs']
settings.COORDS_LIMITS = importSetting['general']['coords_limits']

return settings