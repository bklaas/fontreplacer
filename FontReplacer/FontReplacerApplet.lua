
--[[
=head1 NAME

applets.FontReplacer.FontReplacerApplet - Replace FreeSans.ttf and FreeSansBold.ttf with an alternative

Rather than futz with making Squeezeplay recognize the name of another font, this applet goes with
a brute force approach-- overwrite the existing ttf files with those contained in this applet

The included fonts in this applet package are the product of a font merge between FreeSans and DroidSansFallback
the intention is to allow people to load a font that has CJK (Chinese, Japanese, and Korean) character sets

This does not have any support for R-to-L text rendering, so Hebrew and Arabic are still on the outside looking in :(

=head1 DESCRIPTION

Replaces the stock squeezeplay FreeSans fonts with ones included with this applet

=head1 FUNCTIONS

Applet related methods are described in L<jive.Applet>. 

=cut
--]]


-- stuff we use
local ipairs, tostring = ipairs, tostring

local os			= require("os")
local oo			= require("loop.simple")
local lfs			= require("lfs")
local table			= require("jive.utils.table")
local string		        = require("jive.utils.string")

local Applet		= require("jive.Applet")
local appletManager	= require("jive.AppletManager")
local Framework		= require("jive.ui.Framework")
local Textarea          = require("jive.ui.Textarea")
local Label		= require("jive.ui.Label")
local Group		= require("jive.ui.Group")
local Icon              = require("jive.ui.Icon")
local Window		= require("jive.ui.Window")
local Event		= require("jive.ui.Event")
local SimpleMenu	= require("jive.ui.SimpleMenu")
local Popup 		= require("jive.ui.Popup")
local Task              = require("jive.ui.Task")
local System            = require("jive.System")

local debug		= require("jive.utils.debug")

local FRAME_RATE       = jive.ui.FRAME_RATE
local LAYER_FRAME      = jive.ui.LAYER_FRAME
local LAYER_CONTENT    = jive.ui.LAYER_CONTENT

module(..., Framework.constants)
oo.class(_M, Applet)

function settingsMenu(self)
	-- setup menu
	local window = Window("text_list", self:string("FONT_REPLACER"))
        local menu = SimpleMenu("menu")

	menu:addItem({
		text = self:string('REPLACE_FONT'),
		callback = function() 
			_confirmReplace(self) 
		end
	})

	local header = Textarea('help_text', self:string('REPLACE_FONT_HELP'))
	menu:setHeaderWidget(header)

	window:addWidget(menu)

        self:tieAndShowWindow(window)
	return window
end

function _confirmReplace(self)
	local window = Window("text_list", self:string('REPLACE_FONT'))

	local menu = SimpleMenu("menu", {
		{
			text = self:string("RESET_CANCEL"),
			sound = "WINDOWHIDE",
			callback = function()
				   window:hide()
			end
		},
		{
			text = self:string("RESET_CONTINUE"),
			sound = "WINDOWSHOW",
			callback = function()
				   self:_copyAndRestart()
			end
		},
	})
	local header = Textarea('help_text', self:string('CONTINUE_HELP'))
	menu:setHeaderWidget(header)

        window:addWidget(menu)

        self:tieAndShowWindow(window)
        return window
end


function _copyAndRestart(self)
        local defaultFont        = System:findFile("fonts/FreeSans.ttf")
        local defaultBoldFont    = System:findFile("fonts/FreeSansBold.ttf")

	-- fonts to replace FreeSans.ttf and FreeSansBold.ttf files are called 
	-- NewFont.ttf and NewBoldFont.ttf, respectively
	local newFont            = System:findFile("applets/FontReplacer/NewFont.ttf")
	local newBoldFont        = System:findFile("applets/FontReplacer/NewBoldFont.ttf")

	if newFont or newBoldFont then
		log:warn('Overwriting ttf files in font directory with FontReplacer fonts')
		if newFont then
			os.execute('/bin/mv ' .. newFont .. ' ' .. defaultFont)
		end
		if newBoldFont then
			os.execute('/bin/mv ' .. newBoldFont .. ' ' .. defaultBoldFont)
		end
		self:_restart()
	else
		log:warn('Did not find new fonts')
		log:warn('        defaultFont: ', defaultFont)
		log:warn('    defaultBoldFont: ', defaultBoldFont)
		log:warn('            newFont: ', newFont)
		log:warn('        newBoldFont: ', newBoldFont)
	end

end


function _restart(self)

        local popup = Popup("waiting_popup")
        popup:addWidget(Icon("icon_connected"))
        popup:addWidget(Label("text", self:string("COPIED_FONTS")))
        popup:addWidget(Label("subtext", self:string("RESET_RESETTING")))

        -- make sure this popup remains on screen
        popup:setAllowScreensaver(false)
        popup:setAlwaysOnTop(true)
        popup:setAutoHide(false)

        -- we're shutting down, so prohibit any key presses or holds
        popup:addListener(EVENT_ALL_INPUT,
		function ()
			return EVENT_CONSUME
		end,
		true
	)

        popup:addTimer(4000, 
		function()
			log:info("Reboot for font change to take effect")
			appletManager:callService("reboot")
                        popup:hide()
			appletManager:callService("goHome")
		end,
		true)

        self:tieAndShowWindow(popup)
end


