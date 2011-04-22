
--[[
=head1 NAME

applets.FontReplacer.FontReplacerMeta

=head1 DESCRIPTION

See L<applets.FontReplacer.FontReplacerApplet>.

=head1 FUNCTIONS

See L<jive.AppletMeta> for a description of standard applet meta functions.

=cut
--]]


local oo            = require("loop.simple")

local System        = require("jive.System")
local AppletMeta    = require("jive.AppletMeta")
local appletManager = appletManager
local jiveMain      = jiveMain


module(...)
oo.class(_M, AppletMeta)


function jiveVersion(meta)
	return 1, 1
end


function registerApplet(meta)
	--jiveMain:addItem(meta:menuItem('fontReplacer', 'advancedSettings', "FONT_REPLACER", 
	local newFont = System:findFile("applets/FontReplacer/NewFont.ttf")
	local newBoldFont = System:findFile("applets/FontReplacer/NewBoldFont.ttf")

	if newFont or newBoldFont then
		jiveMain:addItem(meta:menuItem('fontReplacer', 'home', "FONT_REPLACER", 
			function(applet, ...) applet:settingsMenu(...) end, 1, nil, _))
	end
	
end


function configureApplet(self)
end


function defaultSettings(self)
	local defaultSetting = {}
	defaultSetting["fontReplaced"] = false
	return defaultSetting

end

