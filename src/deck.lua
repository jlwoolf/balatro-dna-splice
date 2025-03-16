local ATLAS_KEY = DNA_SPLICE.MOD.id .. "-deck"

DNA_SPLICE.BACK_ATLAS = SMODS.Atlas({
	key = ATLAS_KEY,
	path = "deck.png",
	px = 71,
	py = 95,
})

local config = SMODS.current_mod.config and SMODS.current_mod.config['deck'] or {}

DNA_SPLICE.BACK = SMODS.Back({
	atlas = ATLAS_KEY,
	key = "slug",
	name = "DNA Splice Deck",
	loc_txt = {
		name = "DNA Splice Deck",
		text = {
			"Start with a free",
			"{V:1,T:e_negative}#1#{}{C:attention,T:j_dna}DNA Joker{}",
		},
	},
	pos = { x = 0, y = 0 },
	prefix_config = {
		key = {
			mod = false,
		},
	},
	apply = function(self, back)
		delay(0.4)
		G.E_MANAGER:add_event(Event({
			func = function()
				local dna_card = create_card("Joker", G.jokers, nil, nil, nil, nil, "j_dna", "deck")
				if config.negative then
					dna_card:set_edition({ negative = true }, true)
				end

				dna_card:add_to_deck()
				G.jokers:emplace(dna_card)
				dna_card:start_materialize()
				return true
			end,
		}))
	end,
	inject = function(self)
		self.omit = not config.enabled

		SMODS.Back.super.inject(self)
	end,
	loc_vars = function()
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
