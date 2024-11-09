local function png(name) return ('__Moon_Logic_2__/graphics/%s.png'):format(name) end


-- ----- Main combinator entity

-- Actual visible combinator is "mlc", which uses arithmetic-combinator base
-- Invisible "mlc-core" constant-combinator gets created and connected to its output when placed
-- All signals are set on the invisible combinator, while arithmetic one is only used for reading inputs

-- Combinator looks are based on decider combinator, but behavior is from arithmetic one
-- This is because arithmetic one supports more symbols on the display
local mlc = table.deepcopy(data.raw['arithmetic-combinator']['arithmetic-combinator'])
local decider = data.raw['decider-combinator']['decider-combinator']

mlc.name = 'mlc'
mlc.icon = png('mlc-item')
mlc.icon_mipmaps = 0
mlc.minable = {mining_time=0.2, result='mlc'}
mlc.circuit_wire_max_distance = 7 -- 9 in regular combinators
mlc.max_health = 250 -- 150 for arithmetic/decider
mlc.active_energy_usage = '6kW' -- base=1KW, lamp=5KW

-- *_box, *_sound, damaged_trigger_effect - same

-- Spritesheet here has all same offsets and dimensions as normal (previously hr) version, so copy and change filename
mlc.sprites = table.deepcopy(decider.sprites)
for k, spec in pairs(mlc.sprites) do
	for n, layer in pairs(spec.layers) do
		spec.layers[n] = layer
		if not layer.filename:match('^__base__/graphics/entity/combinator/decider%-combinator')
			then error('decider-combinator sprite sheet incompatibility detected') end
		if not layer.filename:match('%-shadow%.png$')
			then layer.filename = png('mlc-sprites')
			else layer.filename = png('mlc-sprites-shadow') end
end end

-- normal (previously hr-only) symbols from local mlc-displays.png, matching vanilla one in size
for prop, sprites in pairs(mlc) do
	if not prop:match('_symbol_sprites$') then goto skip end
	for dir, spec in pairs(sprites) do
		sprites[dir] = spec
		if spec.filename ~= '__base__/graphics/entity/combinator/combinator-displays.png'
			then error('decider-combinator display symbols sprite sheet incompatibility detected') end
		spec.filename = png('mlc-displays.v2')
		spec.shift = table.deepcopy(decider.greater_symbol_sprites[dir].shift)
end ::skip:: end

-- Copy values from decider that are different in it from arithmetic
for _, k in ipairs{
	'corpse', 'dying_explosion', 'activity_led_sprites',
	'input_connection_points', 'output_connection_points',
	'activity_led_light_offsets', 'screen_light', 'screen_light_offsets',
	'input_connection_points', 'output_connection_points'
} do
	local v = decider[k]
	if type(v) == 'table' then v = table.deepcopy(decider[k]) end
	mlc[k] = v
end

do
	local invisible_sprite = {filename=png('invisible'), width=1, height=1}
	local wire_conn = {wire={red={0, 0}, green={0, 0}}, shadow={red={0, 0}, green={0, 0}}}
	data:extend{ mlc,
		{ type = 'constant-combinator',
			name = 'mlc-core',
			flags = {'placeable-off-grid'},
			-- collision_mask = {},
			item_slot_count = 500,
			circuit_wire_max_distance = 3,
			sprites = invisible_sprite,
			activity_led_sprites = invisible_sprite,
			activity_led_light_offsets = {{0, 0}, {0, 0}, {0, 0}, {0, 0}},
			circuit_wire_connection_points = {wire_conn, wire_conn, wire_conn, wire_conn},
			draw_circuit_wires = false } }
end


-- ----- Other stuff - item, recipe, signal, tech, buttons, keys, etc

data:extend{

	-- Item
  { type = 'item',
		name = 'mlc',
		icon_size = 64,
		icon = png('mlc-item'),
		subgroup = 'circuit-network',
		order = 'c[combinators]-bb[mlc]',
		place_result = 'mlc',
		stack_size = 50 },

	-- Recipe
	{ type = 'recipe',
		name = 'mlc',
		enabled = false,
		ingredients = {
			{ type = 'item', name = 'arithmetic-combinator', amount = 1 },
			{ type = 'item', name = 'decider-combinator', amount = 1 },
			{ type = 'item', name = 'advanced-circuit', amount = 5 } },
		results = {{ type = 'item', name = 'mlc', amount = 1 }} },

	-- Signal
	{ type = 'virtual-signal',
		name = 'mlc-error',
		special_signal = false,
		icon = png('mlc-error'),
		icon_size = 64,
		subgroup = 'virtual-signal',
		order = 'e[signal]-[zzz-mlc-err]' },

	-- Technology
	{ type = 'technology',
		name = 'mlc',
		icon_size = 144,
		icon = png('tech'),
		effects={{type='unlock-recipe', recipe='mlc'}},
		prerequisites = {'circuit-network', 'advanced-circuit'},
		unit = {
		  count = 100,
		  ingredients = {
				{'automation-science-pack', 1},
				{'logistic-science-pack', 1} },
		  time = 15 },
		order = 'a-d-d-z' },

	-- Key bindings
	{ type = 'custom-input',
		name = 'mlc-code-undo',
		key_sequence = 'CONTROL + LEFT',
		order = '01' },
	{ type = 'custom-input',
		name = 'mlc-code-redo',
		key_sequence = 'CONTROL + RIGHT',
		order = '02' },
	{ type = 'custom-input',
		name = 'mlc-code-save',
		key_sequence = 'CONTROL + S',
		order = '03' },
	{ type = 'custom-input',
		name = 'mlc-code-commit',
		key_sequence = 'CONTROL + RETURN',
		order = '04' },
	{ type = 'custom-input',
		name = 'mlc-code-vars',
		key_sequence = 'CONTROL + F',
		order = '05' },
	{ type = 'custom-input',
		name = 'mlc-code-close',
		key_sequence = 'CONTROL + Q',
		order = '06' },
	{ type = 'custom-input',
		name = 'mlc-open-gui',
		key_sequence = 'CONTROL + E',
		order = '07' },

	-- GUI button sprites
	{ type = 'sprite',
		name = 'mlc-fwd',
		filename = png('btn-fwd'),
		priority = 'extra-high-no-scale',
		width = 32,
		height = 32,
		flags = {'no-crop', 'icon'},
		scale = 0.3 },
	{ type = 'sprite',
		name = 'mlc-back',
		filename = png('btn-back'),
		priority = 'extra-high-no-scale',
		width = 32,
		height = 32,
		flags = {'no-crop', 'icon'},
		scale = 0.3 },
	{ type = 'sprite',
		name = 'mlc-fwd-enabled',
		filename = png('btn-fwd-enabled'),
		priority = 'extra-high-no-scale',
		width = 32,
		height = 32,
		flags = {'no-crop', 'icon'},
		scale = 0.3 },
	{ type = 'sprite',
		name = 'mlc-back-enabled',
		filename = png('btn-back-enabled'),
		priority = 'extra-high-no-scale',
		width = 32,
		height = 32,
		flags = {'no-crop', 'icon'},
		scale = 0.3 },
	{ type = 'sprite',
		name = 'mlc-close',
		filename = png('btn-close'),
		priority = 'extra-high-no-scale',
		width = 20,
		height = 20,
		flags = {'no-crop', 'icon'},
		scale = 1 },
	{ type = 'sprite',
		name = 'mlc-help',
		filename = png('btn-help'),
		priority = 'extra-high-no-scale',
		width = 20,
		height = 20,
		flags = {'no-crop', 'icon'},
		scale = 1 },
	{ type = 'sprite',
		name = 'mlc-vars',
		filename = png('btn-vars'),
		priority = 'extra-high-no-scale',
		width = 20,
		height = 20,
		flags = {'no-crop', 'icon'},
		scale = 1 },
	{ type = 'sprite',
		name = 'mlc-clear',
		filename = png('btn-clear'),
		priority = 'extra-high-no-scale',
		width = 20,
		height = 20,
		flags = {'no-crop', 'icon'},
		scale = 1 },

}
