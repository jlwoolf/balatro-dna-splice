local config = SMODS.current_mod.config

---@type 'deck'|'tag'
LAST_SELECTED_CONFIG_TAB = "deck"

---callback for the tag config enabled toggle
---@param enabled any
local function toggle_tag(enabled)
	local tag = SMODS.Tags[DNA_SPLICE.TAG.key]
	if enabled then
		tag:inject()
	else
		G.P_TAGS[DNA_SPLICE.TAG.key] = nil
		SMODS.remove_pool(G.P_CENTER_POOLS[tag.set], tag)
	end
end

---callback for the deck config enabled toggle
---@param enabled any
local function toggle_deck(enabled)
	local deck = SMODS.Centers[DNA_SPLICE.BACK.key]
	if enabled then
		deck:inject()
	else
		deck:delete()
	end
end

---creates the toggles for the config tab
---@param variant 'deck'|'tag'
---@return table
local function create_config_toggles(variant, callback)
	return {
		n = G.UIT.C,
		config = {
			align = "cm",
			r = 0.2,
			colour = G.C.CLEAR,
			emboss = 0.05,
			padding = 0.2,
			minw = 4,
		},
		nodes = {
			CONFIG_API.create_toggle({
				label = "Enabled",
				ref_table = config and config[variant] or {},
				ref_value = "enabled",
				callback = callback,
			}),
			CONFIG_API.create_toggle({
				label = "Negative Joker",
				ref_table = config and config[variant] or {},
				ref_value = "negative",
			}),
		},
	}
end

DNA_SPLICE.CONFIG_UI = {
	tag = {
		order = 2,
		custom = {
			type = "custom",
			build = function()
				return {
					n = G.UIT.ROOT,
					config = { colour = G.C.CLEAR },
					nodes = {
						{
							n = G.UIT.R,
							config = { align = "cm", colour = G.C.CLEAR, r = 0.2 },
							nodes = {
								{
									n = G.UIT.C,
									config = { align = "cm", padding = 0 },
									nodes = {
										CONFIG_API.UI.create_tag({ atlas = SMODS.Tags[DNA_SPLICE.TAG.key].atlas }),
									},
								},
								create_config_toggles("tag", toggle_tag),
							},
						},
					},
				}
			end,
		},
	},
	deck = {
		order = 1,
		custom = {
			type = "custom",
			build = function()
				return {
					n = G.UIT.ROOT,
					config = { colour = G.C.CLEAR },
					nodes = {
						{
							n = G.UIT.R,
							config = { align = "cm", colour = G.C.CLEAR, r = 0.2 },
							nodes = {
								{
									n = G.UIT.C,
									config = { align = "cm", padding = 0 },
									nodes = {
										CONFIG_API.UI.create_deck({ deck = Back(SMODS.Centers[DNA_SPLICE.BACK.key]) }),
									},
								},
								create_config_toggles("deck", toggle_deck),
							},
						},
					},
				}
			end,
		},
	},
}
