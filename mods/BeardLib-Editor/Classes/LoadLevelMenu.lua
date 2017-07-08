LoadLevelMenu = LoadLevelMenu or class()
function LoadLevelMenu:init()
	local menu = BeardLibEditor.managers.Menu
	self._menu = menu:make_page("Levels", nil, {scrollbar = false})
	MenuUtils:new(self)
	local tabs = self:Menu("Tabs", {align_method = "grid", offset = 0, auto_height = true})
	local opt = {size_by_text = true, group = tabs, color = tabs.accent_color, offset = 0}
	local w = self:Toggle("Localized", callback(self, self, "load_levels"), false, opt).w
	w = w + self:Toggle("Vanilla", callback(self, self, "load_levels"), false, opt).w
	w = w + self:Toggle("Custom", callback(self, self, "load_levels"), true, opt).w
	local search = self:TextBox("Search", callback(self, self, "load_levels"), nil, {w = tabs.w - w, group = tabs, index = 1, control_slice = 1.2, offset = 0})
	local levels = self:Menu("Levels", {align_method = "grid", h = self._menu:Panel():h() - search:Panel():h(), auto_height = false})
	self:load_levels()
end

function LoadLevelMenu:load_levels()
	local searching = self:GetItem("Search"):Value()
	local vanilla = self:GetItem("Vanilla"):Value()
	local custom = self:GetItem("Custom"):Value()
    local columns = BeardLibEditor.Options:GetValue("LevelsColumns")
    local loc = self:GetItem("Localized")
    local levels = self:GetItem("Levels")
    levels:ClearItems("levels")

    for id, level in pairs(tweak_data.levels) do
        if level.world_name and ((level.custom and custom) or (not level.custom and vanilla)) then
            local text = loc:Value() and managers.localization:text(tostring(level.name_id)) or id
            if not searching or searching == "" or text:match(searching) then
                levels:Button({
                    name = id,
                    vanilla = not level.custom,
                    w = levels:ItemsWidth() / columns,
                    offset = {0, levels:Offset()[2]},
                    text = text,
                    callback = callback(self, self, "load_level"),
                    label = "levels",
                })  
            end
        end
    end
end

function LoadLevelMenu:load_level(menu, item)
    local level_id = item.name
    local function load(safe_mode)
        Global.editor_mode = true
        Global.editor_safe_mode = safe_mode == true
        MenuCallbackHandler:play_single_player()
        Global.game_settings.level_id = level_id
        Global.game_settings.mission = "none"
        Global.game_settings.difficulty = "normal"
        Global.game_settings.world_setting = nil
        MenuCallbackHandler:start_the_game()    
        BeardLibEditor.managers.Menu:set_enabled(false)
    end
    if item.vanilla then
        BeardLibEditor.Utils:QuickDialog({title = "Preview level '" .. tostring(level_id).."'?", message = "Since this is a vanilla heist you can only preview it, clone the heist if you wish to edit the heist!"}, {{"Load", load}})
    else
        BeardLibEditor.Utils:QuickDialog({title = "Edit level '" .. tostring(level_id).."'?", message = "Choose load method, normal is the default load and safe is used to load/remove unloaded units"}, {
            {"Load Normally", load}, {"Load Safely", SimpleClbk(load, true)}
        })
    end
end