local wezterm = require("wezterm")
local mux = wezterm.mux

-- This will hold the configuration.
local config = wezterm.config_builder()
local line_ending = "\n"
local font_size = 12.0

local is_macos = wezterm.target_triple:find("apple%-darwin") ~= nil

if os.getenv("OS") == "Windows_NT" then
	config.default_prog = { "pwsh.exe" }
	line_ending = "\r\n"
    font_size = 10.0
end

if is_macos then
	-- Treat left Option as Meta instead of composing accented characters,
	-- so the Alt-based tmux bindings (M-hjkl, M-H/M-L) work.
	config.send_composed_key_when_left_alt_is_pressed = false
	config.send_composed_key_when_right_alt_is_pressed = true
end

-- This is where you actually apply your config choices

-- For example, changing the color scheme:
config.color_scheme = "catppuccin-mocha"
config.font = wezterm.font("JetBrainsMono Nerd Font", { weight = "Regular" })
config.font_size = font_size
-- config.hide_tab_bar_if_only_one_tab = true
config.tab_bar_at_bottom = true
config.window_decorations = 'RESIZE'
config.default_cursor_style = 'SteadyBar'
config.front_end = "WebGpu"

config.keys = {
	{
		key = "t",
		mods = 'CTRL|SHIFT|ALT',
		action = wezterm.action_callback(function(_, pane)
			local tab = pane:tab()
			local panes = tab:panes_with_info()
			if #panes == 1 then
				pane:split({
					direction = "Right",
					size = 0.4,
				})
			elseif not panes[1].is_zoomed then
				panes[1].pane:activate()
				tab:set_zoomed(true)
			elseif panes[1].is_zoomed then
				tab:set_zoomed(false)
				panes[2].pane:activate()
			end
		end),
	},
}

wezterm.on("gui-startup", function(_)
	local spawn_args = {
		workspace = "main",
	}
    local first_title = "1st"
	if os.getenv("OS") == "Windows_NT" then
		spawn_args.args = { "ubuntu.exe" }
        first_title = "ubuntu"
	end
	local shell_tab, _, window = mux.spawn_window(spawn_args)
    shell_tab:set_title(first_title)

	-- if os.getenv("OS") == "Windows_NT" then
	-- 	window:spawn_tab({ args = { "pwsh.exe" } })
	-- end

	window:gui_window():maximize()

	mux.set_active_workspace = "main"
	shell_tab:activate()
end)

-- and finally, return the configuration to wezterm
return config
