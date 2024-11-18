local wezterm = require("wezterm")
local mux = wezterm.mux

-- This will hold the configuration.
local config = wezterm.config_builder()
local line_ending = "\n"

if os.getenv("OS") == "Windows_NT" then
	config.default_prog = { "pwsh.exe" }
	line_ending = "\r\n"
end

-- This is where you actually apply your config choices

-- For example, changing the color scheme:
config.color_scheme = "catppuccin-macchiato"
config.font_size = 11.0
-- config.hide_tab_bar_if_only_one_tab = true
config.tab_bar_at_bottom = true
config.window_decorations = 'RESIZE'

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

wezterm.on("gui-startup", function(cmd)
	local shell_tab, _, window = mux.spawn_window({
		workspace = "main",
		args = cmd,
	})
	shell_tab:set_title("1st")

	-- local editor_tab, _, _ = window:spawn_tab({})
	-- editor_tab:set_title("Editor")
	--
	-- local second_brain_tab, second_brain_pane, _ = window:spawn_tab({
	-- 	cwd = wezterm.home_dir .. "/OneDrive - UiPath/Documents/SecondWorkBrain/",
	-- })
	-- second_brain_tab:set_title("SecondBrain")
	-- second_brain_pane:send_text("nvim" .. line_ending)
	-- second_brain_pane:split({ direction = "Right" })

	window:gui_window():maximize()

	mux.set_active_workspace = "main"
	shell_tab:activate()
end)

-- and finally, return the configuration to wezterm
return config
