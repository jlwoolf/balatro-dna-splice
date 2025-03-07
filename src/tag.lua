local config = DNA_SPLICE.CONFIG["tag"]

SMODS.Atlas({
	key = "dna_splice_tag",
	path = "dna_splice_tag.png",
	px = 34,
	py = 34,
})

SMODS.Tag({
	atlas = "dna_splice_tag",
	config = {
		type = "store_joker_create",
	},
	discovered = true,
	key = "dna_splice",
	in_pool = function()
		return config and config["tag"]["enabled"] or false
	end,
	loc_txt = {
		name = "DNA Splice Tag",
		text = {
			"Shop has a free",
			"{V:1}#1#{}{C:attention}DNA Joker{}",
		},
	},
	name = "DNA Splice Tag",
	prefix_config = {
		key = {
			mod = false,
		},
	},
	apply = function(self, tag, context)
		if tag.triggered then
			return
		end

		if tag.config.type ~= context.type then
			return
		end

		local dna_card = create_card("Joker", context.area, nil, nil, nil, nil, "j_dna")
		create_shop_card_ui(dna_card, "Joker", context.area)

		dna_card.states.visible = false
		tag:yep("+", G.C.BLUE, function()
			dna_card:start_materialize()

			if config.negative then
				dna_card:set_edition({ negative = true }, true)
			end

			dna_card.ability.couponed = true
			dna_card:set_cost()
			return true
		end)

		G.shop_jokers:emplace(dna_card)
		dna_card:juice_up()

		tag.triggered = true
	end,
	inject = function(self)
		if config.enabled then
			G.P_TAGS[self.key] = self
			SMODS.insert_pool(G.P_CENTER_POOLS[self.set], self)
		end
	end,
	loc_vars = function(self, info_queue, card)
		if config.negative then
			info_queue[#info_queue + 1] = G.P_CENTERS.e_negative
		end

		info_queue[#info_queue + 1] = G.P_CENTERS.j_dna
		return {
			vars = {
				config.negative and "Negative " or "",
				colours = {
					G.C.DARK_EDITION,
				},
			},
		}
	end,
})
