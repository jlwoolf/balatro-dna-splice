local config = DNA_SPLICE.CONFIG

---@type 'deck'|'tag'
LAST_SELECTED_CONFIG_TAB = "deck"

---callback for the tag config enabled toggle
---@param enabled any
local function toggle_tag(enabled)
	local tag = SMODS.Tags[DNA_SPLICE.TAG.key]
	if enabled then
		G.P_TAGS[DNA_SPLICE.TAG.key] = tag
		SMODS.insert_pool(G.P_CENTER_POOLS[tag.set], tag)
	else
		G.P_TAGS[DNA_SPLICE.TAG.key] = nil
		SMODS.remove_pool(G.P_CENTER_POOLS[tag.set], tag)
	end
end

---callback for the deck config enabled toggle
---@param enabled any
local function toggle_deck(enabled)
	local deck = SMODS.Centers[DNA_SPLICE.BACK.key]
	deck.omit = not enabled
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
			create_toggle({
				label = "Enabled",
				ref_table = config and config[variant] or {},
				ref_value = "enabled",
				callback = callback,
				w = 1,
			}),
			create_toggle({
				label = "Negative Joker",
				w = 1,
				ref_table = config and config[variant] or {},
				ref_value = "negative",
			}),
		},
	}
end

---creates the tag node for the tag tab in the config
---@return table
local function create_dna_tag_node()
	--- copied over from Tag:generate_UI but removed dependencies that come from
	--- actual tag definition. This way sprite can render without tag enabled
	local tag_sprite = Sprite(0, 0, 0.8, 0.8, G.ASSET_ATLAS[DNA_SPLICE.TAG.atlas], { x = 0, y = 0 })
	tag_sprite.T.scale = 1
	tag_sprite.float = true
	tag_sprite.states.hover.can = true
	tag_sprite.states.drag.can = false
	tag_sprite.states.collide.can = true
	tag_sprite.config = { force_focus = true }

	tag_sprite:define_draw_steps({
		{ shader = "dissolve", shadow_height = 0.05 },
		{ shader = "dissolve" },
	})

	tag_sprite.hover = function(_self)
		if not G.CONTROLLER.dragging.target or G.CONTROLLER.using_touch then
			if not _self.hovering and _self.states.visible then
				_self.hovering = true
				if _self == tag_sprite then
					_self.hover_tilt = 3
					_self:juice_up(0.05, 0.02)
					play_sound("paper1", math.random() * 0.1 + 0.55, 0.42)
					play_sound("tarot2", math.random() * 0.1 + 0.55, 0.09)
				end

				Node.hover(_self)
				if _self.children.alert then
					_self.children.alert:remove()
					_self.children.alert = nil
					G:save_progress()
				end
			end
		end
	end

	tag_sprite.stop_hover = function(_self)
		_self.hovering = false
		Node.stop_hover(_self)
		_self.hover_tilt = 0
	end

	local tag_sprite_tab = {
		n = G.UIT.C,
		config = { align = "cm" },
		nodes = {
			{
				n = G.UIT.O,
				config = {
					w = 0.8,
					h = 0.8,
					colour = G.C.BLUE,
					object = tag_sprite,
					focus_with_object = true,
				},
			},
		},
	}

	return {
		n = G.UIT.C,
		config = { align = "cm", padding = 0.1 },
		nodes = {
			tag_sprite_tab,
		},
	}
end

---creates the card node for the card tab in the config
---@return table
local function create_dna_card_node()
	local area = CardArea(
		G.ROOM.T.x + 0.2 * G.ROOM.T.w / 2,
		G.ROOM.T.h,
		G.CARD_W,
		G.CARD_H,
		{ card_limit = 5, type = "deck", highlight_limit = 0, deck_height = 0.75, thin_draw = 1 }
	)

	G.GAME.viewed_back = Back(SMODS.Centers[DNA_SPLICE.BACK.key])

	for i = 1, 10 do
		local card = Card(
			G.ROOM.T.x + 0.2 * G.ROOM.T.w / 2,
			G.ROOM.T.h,
			G.CARD_W,
			G.CARD_H,
			pseudorandom_element(G.P_CARDS),
			G.P_CENTERS.c_base,
			{ playing_card = i, viewed_back = true }
		)
		card.sprite_facing = "back"
		card.facing = "back"
		area:emplace(card)
	end

	return { n = G.UIT.O, config = { object = area } }
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
									nodes = { create_dna_tag_node() },
								},
								create_config_toggles("tag", toggle_deck),
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
									nodes = { create_dna_card_node() },
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
