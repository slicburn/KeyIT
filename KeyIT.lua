-----------------------------------------------------------------------------------------------
-- Client Lua Script for KeyIT
-----------------------------------------------------------------------------------------------
 
require "Window"
require "GameLib"
require "Apollo"
 
-----------------------------------------------------------------------------------------------
-- KeyIT Module Definition
-----------------------------------------------------------------------------------------------
local KeyIT = {} 
local foxyLib =  nil 

-----------------------------------------------------------------------------------------------
-- Local Default Settings
-----------------------------------------------------------------------------------------------

local defaultSettings = {
	  wndPosition = {
		[1] = {-680, -196, 764, -196},
	  },
	-- other settings
	debug = false,
}
-----------------------------------------------------------------------------------------------
-- Constants
-----------------------------------------------------------------------------------------------
-- e.g. local kiExampleVariableMax = 999

local WINDOW_SIZE = 51
 
-----------------------------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------------------------
function KeyIT:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self 

    -- initialize variables here

    return o
end

function KeyIT:Init()
	local bHasConfigureFunction = false
	local strConfigureButtonText = "KeyIT"
	local tDependencies = {
		-- "UnitOrPackageName",
		"FoxyLib-1.0"
	}
    Apollo.RegisterAddon(self, bHasConfigureFunction, strConfigureButtonText, tDependencies)
end

-----------------------------------------------------------------------------------------------
-- Save & Restore settings
-----------------------------------------------------------------------------------------------

function KeyIT:OnSave(eType)
	if eType ~= GameLib.CodeEnumAddonSaveLevel.Character then
		return nil
	end

    local tSave = {}
   
	-- windows form positions 
	tSave.wndPosition = foxyLib.DeepCopy(self.userSettings.wndPosition)
	
	return tSave
end


function KeyIT:OnRestore(eType, tSave)
	if eType ~= GameLib.CodeEnumAddonSaveLevel.Character then
		return
	end
	
	-- windows form positions 
	if tSave.wndPosition then
		self.userSettings.wndPosition = foxyLib.DeepCopy(tSave.wndPosition)
	else
		self.userSettings.wndPosition = foxyLib.DeepCopy(defaultSettings.wndPosition)
	end
	 
	
	self.onRestoreCalled = true
	self:SetupWnd()
	
end
 

-----------------------------------------------------------------------------------------------
-- KeyIT OnLoad
-----------------------------------------------------------------------------------------------
function KeyIT:OnLoad()
	-- Load Lib
	foxyLib = Apollo.GetPackage("FoxyLib-1.0").tPackage
	
	-- Initialize the fields
	self.userSettings = foxyLib.DeepCopy(defaultSettings)
	self.onRestoreCalled = false
	self.onXmlDocLoadedCalled = false
	self.locale = foxyLib.GetLocale();
	
	
    -- load our form file
	self.xmlDoc = XmlDoc.CreateFromFile("KeyIT.xml")
	self.xmlDoc:RegisterCallback("OnDocLoaded", self)
end

-----------------------------------------------------------------------------------------------
-- KeyIT OnDocLoaded
-----------------------------------------------------------------------------------------------
function KeyIT:OnDocLoaded()

	if self.xmlDoc ~= nil and self.xmlDoc:IsLoaded() then
	    self.wndMain = Apollo.LoadForm(self.xmlDoc, "KeyITForm", nil, self)
		if self.wndMain == nil then
			Apollo.AddAddonErrorText(self, "Could not load the main window for some reason.")
			return
		end
		
	    self.wndMain:Show(true, true)

		-- if the xmlDoc is no longer needed, you should set it to nil
		-- self.xmlDoc = nil
		
		-- Register handlers for events, slash commands and timer, etc.
		-- e.g. Apollo.RegisterEventHandler("KeyDown", "OnKeyDown", self)
		Apollo.RegisterSlashCommand("KeyIT", "OnKeyITOn", self)

		self.timer = ApolloTimer.Create(1.0, true, "OnTimer", self)

		-- Do additional Addon initialization here
		self:SetupWnd()
		
	end
end

-----------------------------------------------------------------------------------------------
-- KeyIT Functions
-----------------------------------------------------------------------------------------------
-- Define general functions here

-- restore window location
function KeyIT:SetupWnd()
if not self.onRestoreCalled or not self.onXmlDocLoadedCalled then
	return
end
	for index, wndMain in pairs(self.twndMain) do
	local anchors = self.userSettings.wndPosition[index]
		wndMain:SetAnchorOffsets(anchors[1] + WINDOW_SIZE )
	end
end

-- on SlashCommand "/KeyIT"
function KeyIT:OnKeyITOn()
	self.wndMain:Invoke() -- show the window
end

-- on timer
function KeyIT:OnTimer()
	-- Do your timer-related stuff here.
end


-----------------------------------------------------------------------------------------------
-- KeyITForm Functions
-----------------------------------------------------------------------------------------------
-- when the OK button is clicked
function KeyIT:OnOK()
self.eCurrKeySet = GameLib.GetCurrInputKeySet()

-- debug
self:Debug("Current KeySet: ", self.eCurrKeySet) 
self:Debug("Current Spec: ", AbilityBook.GetCurrentSpec() )



Sound.Play(126)

	if self.eCurrKeySet == 3 then
			
			-- action set 1
			AbilityBook.PrevSpec()
						
			-- Char Keybind Set
			self.eCurrKeySet = 4
			Apollo.SetConsoleVariable("spell.disableAutoTargeting", false) -- disable auto target
			Apollo.SetConsoleVariable("player.disableFacingLock", false) -- pve lock target 
			Apollo.SetConsoleVariable("player.ignoreAlwaysFaceTarget", false) -- pve auto face target 
			Apollo.SetConsoleVariable("spell.autoSelectCharacter", true) -- auto self-cast
			Apollo.SetConsoleVariable("video.exclusive", false) -- video window 
			Apollo.SetConsoleVariable("video.fullscreen", false) -- full screen window
			Apollo.SetConsoleVariable("player.moveToTargetOnSelfAOE", true) -- move to target
			local bCompleted = GameLib.SetCurrInputKeySet(self.eCurrKeySet) -- SetCurrInputKeySet return FALSE if still need to wait for server to send client the keybindings
			
			-- debug
			self:Debug("Keyset is now: ", GameLib.GetCurrInputKeySet() )
			self:Debug("Spec is now: ", AbilityBook.GetCurrentSpec() ) 
			
	else
		
			-- action set 2
			AbilityBook.NextSpec()
			
			-- Account Keybind Set
			self.eCurrKeySet = 3    
			Apollo.SetConsoleVariable("spell.disableAutoTargeting", true) -- disable auto target
			Apollo.SetConsoleVariable("player.disableFacingLock", true)   -- pve lock target
			Apollo.SetConsoleVariable("player.ignoreAlwaysFaceTarget", true) -- auto face target 
			Apollo.SetConsoleVariable("spell.autoSelectCharacter", false) -- auto self-cast     
			Apollo.SetConsoleVariable("video.exclusive", false) -- video window 
			Apollo.SetConsoleVariable("video.fullscreen", true) -- full screen window 
			Apollo.SetConsoleVariable("player.moveToTargetOnSelfAOE", false) -- move to target                                                   
			local bCompleted = GameLib.SetCurrInputKeySet(self.eCurrKeySet) -- SetCurrInputKeySet return FALSE if still need to wait for server to send client the keybindings
			
			-- debug
			self:Debug("Keyset is now: ", GameLib.GetCurrInputKeySet() )
			self:Debug("Spec is now: ", AbilityBook.GetCurrentSpec() )  
				       
	end
	
end

-- when the Cancel button is clicked
function KeyIT:OnCancel()
	self.wndMain:Close() -- hide the window
end

-----------------------------------------------------------------------------------------------
-- Debug
-----------------------------------------------------------------------------------------------
function KeyIT:Debug(message, error)
	if defaultSettings.debug == true then
		Print(message .. error)
	end
end


-----------------------------------------------------------------------------------------------
-- KeyIT Instance
-----------------------------------------------------------------------------------------------
local KeyITInst = KeyIT:new()
KeyITInst:Init()
