local AddonName, Addon = ...
local ParentAddonName = GetAddOnDependencies(AddonName)
local ParentAddon = _G[ParentAddonName]
local L = LibStub('AceLocale-3.0'):GetLocale(ParentAddonName .. '-Config')

local AddonOptionsPanel = Addon:CreateClass('Frame')
do
	function AddonOptionsPanel:New(owner, parent)
		local frame = self:Bind(CreateFrame('Frame', nil, parent or owner))

		frame:SetAllPoints(frame:GetParent())
		frame:Hide()

		return frame
	end

	function AddonOptionsPanel:Add(widget, options)
		options.parent = self

		return Addon[widget]:New(options)
	end
end

local AddonOptions = CreateFrame('Frame', ('%sOptions'):format(ParentAddonName), _G.UIParent)
do
	AddonOptions.insets = 16

	function AddonOptions:Initialize()
		self.panels = {}
		self.name = ParentAddonName

		local title, description = select(2, GetAddOnInfo(ParentAddonName))

		local titleText = self:CreateFontString(nil, 'ARTWORK', 'GameFontNormalLarge')
		titleText:SetPoint('TOPLEFT', self.insets, -self.insets)
		titleText:SetText(title)

		local descriptionText = self:CreateFontString(nil, 'ARTWORK', 'GameFontHighlightSmall')
		descriptionText:SetPoint('TOPLEFT', titleText, 'BOTTOMLEFT', 0, -8)
		descriptionText:SetText(description)

		-- panel selector
		local panelSelector = Addon.PanelSelector:New(self)
		panelSelector:SetPoint('TOPLEFT', descriptionText, 'BOTTOMLEFT', 0, -4)
		panelSelector:SetPoint('RIGHT', -self.insets, 0)
		panelSelector:SetHeight(20)
		panelSelector.OnSelect = function(_, id) self:ShowPanel(id) end
		self.panelSelector = panelSelector

		-- panel container
		local panelContainer = CreateFrame('Frame', nil, self)
		panelContainer:SetPoint('TOPLEFT', panelSelector, 'BOTTOMLEFT', 0, -4)
		panelContainer:SetPoint('BOTTOMRIGHT', -self.insets, self.insets)

		self.panelContainer = panelContainer

		self:SetScript('OnShow', self.OnShow)
		self:Hide()

		InterfaceOptions_AddCategory(self)

		self:InitializeAce()
	end

	function AddonOptions:InitializeAce()
		local AceConfigDialog = LibStub("AceConfigDialog-3.0")
		local AceRegistry = LibStub("AceConfigRegistry-3.0")

		local options = {
			type = "group",
			name = "Dominos",
			args = {}
		}
		
		options.args.profile = LibStub("AceDBOptions-3.0"):GetOptionsTable(ParentAddon.db, true)
		local LibDualSpec = LibStub("LibDualSpec-1.0", true)
		if LibDualSpec then LibDualSpec:EnhanceOptions(options.args.profile, ParentAddon.db) end

		options.args.profile.order = 1

		AceRegistry:RegisterOptionsTable(ParentAddonName, options, true)

		AceConfigDialog:AddToBlizOptions(ParentAddonName, "Profiles", self.name, "profile")
	end

	function AddonOptions:OnShow()
		self.panelSelector:Select(L.General)
	end

	function AddonOptions:NewPanel(id)
		self.panelSelector:AddPanel(id)

		local panel = AddonOptionsPanel:New(self, self.panelContainer)
		self.panels[id] = panel

		return panel
	end

	function AddonOptions:ShowPanel(id)
		if self.panels then
			for i, panel in pairs(self.panels) do
				if i == id then
					panel:Show()
				else
					panel:Hide()
				end
			end
		end
	end

	AddonOptions:Initialize()
end

Addon.AddonOptions = AddonOptions

function Addon:ShowAddonPanel()
	InterfaceOptionsFrame_Show()
	InterfaceOptionsFrame_OpenToCategory(ParentAddonName)
end
