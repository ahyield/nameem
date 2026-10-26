# Mission Control reuses the app's sign-in and admin check (see MissionControlBaseController) rather than
# a separate HTTP basic auth password. Set on the module: the engine has already read config.mission_control
# by the time initializers run.
MissionControl::Jobs.base_controller_class = "MissionControlBaseController"
MissionControl::Jobs.http_basic_auth_enabled = false
