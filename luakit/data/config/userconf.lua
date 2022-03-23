local select = require "select"
local settings = require "settings"
local modes = require "modes"
local msg = require "msg"

select.label_maker = function ()
  local chars = charset("asdjkl")
  return trim(sort(reverse(chars)))
end

local safe_mode = "S"
local images = "i"

-- enable/disable 'safe' mode
local function enable_disable_nonsafe_mode (opt)
  local opts = {
    "webview.allow_file_access_from_file_urls",
    "webview.allow_modal_dialogs",
    "webview.allow_universal_access_from_file_urls",
    "webview.enable_accelerated_2d_canvas",
    "webview.enable_fullscreen",
    "webview.enable_html5_database",
    "webview.enable_html5_local_storage",
    "webview.enable_javascript",
    "webview.enable_media_stream",
    "webview.enable_offline_web_application_cache",
    "webview.enable_webaudio",
    "webview.enable_webgl",
    "webview.javascript_can_access_clipboard",
    "webview.javascript_can_open_windows_automatically",
  }

  for i = 1, #(opts) do
    settings.override_setting(opts[i], opt)
  end

  if opt then
    safe_mode = "s"
  else
    safe_mode = "S"
  end
end

modes.add_binds("normal", {
  { "sd", "Disable nonsafe mode", function ()
    enable_disable_nonsafe_mode(false)
    msg.debug("Disabled nonsafe mode")
  end},
  { "se", "Enable nonsafe mode", function ()
    enable_disable_nonsafe_mode(true)
    msg.debug("Enabled nonsafe mode")
  end},
})

local window = require "window"

window.add_signal("build", function (w)
    local widgets, l, r = require "lousy.widget", w.sbar.l, w.sbar.r

    -- Left-aligned status bar widgets
    l.layout:pack(widgets.uri())
    l.layout:pack(widgets.hist())
    l.layout:pack(widgets.progress())

    -- Right-aligned status bar widgets
    r.layout:pack(widgets.buf())
    r.layout:pack(widgets.ssl())
    r.layout:pack(widgets.tabi())
    r.layout:pack(widgets.scroll())
end)
