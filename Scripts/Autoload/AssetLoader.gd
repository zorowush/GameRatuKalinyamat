extends Node
## Memuat aset dari Assets/ jika tersedia, atau membangkitkan placeholder rapi
## bertema Relief Mantingan (bata merah, krem, hijau-biru laut, emas, cokelat tua).

const COLOR_TERRACOTTA := Color("#9E3B2B")
const COLOR_TERRACOTTA_DARK := Color("#74281C")
const COLOR_CREAM := Color("#F5EAD6")
const COLOR_CREAM_DARK := Color("#E2D0B1")
const COLOR_SEA_TEAL := Color("#1E6B7B")
const COLOR_SEA_TEAL_DARK := Color("#144954")
const COLOR_GOLD := Color("#D4A24C")
const COLOR_GOLD_DARK := Color("#9E7429")
const COLOR_DARK_BROWN := Color("#3B2418")
const COLOR_PANEL_DARK := Color("#2B1A12")
const COLOR_BG_DEEP := Color("#1E120C")
const COLOR_SUCCESS := Color("#2E7D4F")
const COLOR_ERROR := Color("#B83227")

const COLOR_TAG_FAKTA := Color("#1E6B7B")
const COLOR_TAG_TRADISI := Color("#B87D23")
const COLOR_TAG_FIKSI := Color("#9E3B2B")

var _texture_cache: Dictionary = {}
var _cached_theme: Theme = null


func load_json_file(path: String) -> Variant:
	if not FileAccess.file_exists(path):
		push_error("[AssetLoader] File JSON tidak ditemukan: %s" % path)
		return null
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("[AssetLoader] Gagal membuka file JSON: %s" % path)
		return null
	var text := file.get_as_text()
	file.close()
	var json := JSON.new()
	var err := json.parse(text)
	if err != OK:
		push_error("[AssetLoader] JSON tidak valid di %s (baris %d): %s" % [path, json.get_error_line(), json.get_error_message()])
		return null
	return json.data


func load_texture_or_placeholder(
	path: String,
	size: Vector2i = Vector2i(96, 96),
	bg_color: Color = COLOR_TERRACOTTA,
	accent_color: Color = COLOR_GOLD,
	motif: String = "crest"
) -> Texture2D:
	if not path.is_empty() and ResourceLoader.exists(path):
		var loaded := load(path)
		if loaded is Texture2D:
			return loaded

	var cache_key := "%s_%dx%d_%s_%s_%s" % [path, size.x, size.y, bg_color.to_html(), accent_color.to_html(), motif]
	if _texture_cache.has(cache_key):
		return _texture_cache[cache_key]

	var w := maxi(16, size.x)
	var h := maxi(16, size.y)
	var img := Image.create_empty(w, h, false, Image.FORMAT_RGBA8)
	img.fill(bg_color)

	var border := maxi(3, mini(w, h) / 16)
	for x in range(w):
		for y in range(h):
			if x < border or x >= w - border or y < border or y >= h - border:
				img.set_pixel(x, y, accent_color)
			elif x < border + 2 or x >= w - border - 2 or y < border + 2 or y >= h - border - 2:
				img.set_pixel(x, y, COLOR_DARK_BROWN)

	_draw_motif(img, w, h, motif, accent_color)
	var tex := ImageTexture.create_from_image(img)
	_texture_cache[cache_key] = tex
	return tex


func _draw_motif(img: Image, w: int, h: int, motif: String, accent: Color) -> void:
	var cx := w / 2
	var cy := h / 2
	var r := mini(w, h) / 4

	match motif:
		"crown", "player":
			# Siluet mahkota / tokoh bangsawan Jepara
			for x in range(cx - r, cx + r):
				for y in range(cy + r / 3, cy + r):
					img.set_pixel(clampi(x, 0, w - 1), clampi(y, 0, h - 1), COLOR_CREAM)
			for x in range(cx - r / 2, cx + r / 2):
				for y in range(cy - r / 2, cy + r / 4):
					if (x - cx) * (x - cx) + (y - (cy - r / 8)) * (y - (cy - r / 8)) <= (r / 2) * (r / 2):
						img.set_pixel(clampi(x, 0, w - 1), clampi(y, 0, h - 1), COLOR_CREAM)
			# Puncak mahkota emas
			for x in range(cx - r / 2, cx + r / 2):
				for y in range(cy - r, cy - r / 2):
					if absi(x - cx) <= (y - (cy - r)) + 3:
						img.set_pixel(clampi(x, 0, w - 1), clampi(y, 0, h - 1), accent)
		"scroll", "archive":
			# Gulungan arsip sejarah
			for x in range(cx - r, cx + r):
				for y in range(cy - r + 4, cy + r - 4):
					img.set_pixel(clampi(x, 0, w - 1), clampi(y, 0, h - 1), COLOR_CREAM)
			for line_idx in range(3):
				var ly := cy - r / 2 + line_idx * maxi(4, r / 2)
				for x in range(cx - r + 8, cx + r - 8):
					if ly >= 0 and ly < h:
						img.set_pixel(clampi(x, 0, w - 1), ly, COLOR_DARK_BROWN)
		"ship", "fleet":
			# Siluet kapal jung maritim Jepara
			for x in range(cx - r, cx + r):
				for y in range(cy + 2, cy + r / 2 + 4):
					if absi(x - cx) < r - (y - cy) / 2:
						img.set_pixel(clampi(x, 0, w - 1), clampi(y, 0, h - 1), COLOR_DARK_BROWN)
			# Layar kapal
			for y in range(cy - r, cy + 2):
				var span := maxi(2, int(float(y - (cy - r)) * 0.7))
				for x in range(cx - span / 2, cx + span):
					img.set_pixel(clampi(x, 0, w - 1), clampi(y, 0, h - 1), COLOR_CREAM)
		"challenge":
			# Berlian / bintang tantangan
			for x in range(cx - r, cx + r):
				for y in range(cy - r, cy + r):
					if absi(x - cx) + absi(y - cy) <= r:
						img.set_pixel(clampi(x, 0, w - 1), clampi(y, 0, h - 1), accent)
					elif absi(x - cx) + absi(y - cy) <= r + 3:
						img.set_pixel(clampi(x, 0, w - 1), clampi(y, 0, h - 1), COLOR_CREAM)
		"gate":
			# Gapura Mantingan
			for x in range(cx - r, cx - r / 3):
				for y in range(cy - r, cy + r):
					img.set_pixel(clampi(x, 0, w - 1), clampi(y, 0, h - 1), accent)
			for x in range(cx + r / 3, cx + r):
				for y in range(cy - r, cy + r):
					img.set_pixel(clampi(x, 0, w - 1), clampi(y, 0, h - 1), accent)
			for x in range(cx - r - 3, cx + r + 3):
				for y in range(cy - r - 2, cy - r / 2):
					img.set_pixel(clampi(x, 0, w - 1), clampi(y, 0, h - 1), COLOR_CREAM)
		_:
			# Motif ornamen belah ketupat Mantingan
			for x in range(cx - r, cx + r):
				for y in range(cy - r, cy + r):
					var dist := absi(x - cx) + absi(y - cy)
					if dist <= r and dist >= r - 4:
						img.set_pixel(clampi(x, 0, w - 1), clampi(y, 0, h - 1), accent)


func load_audio_or_null(path: String) -> AudioStream:
	if not path.is_empty() and ResourceLoader.exists(path):
		var loaded := load(path)
		if loaded is AudioStream:
			return loaded
	return null


func get_tag_color(source_tag: String) -> Color:
	match source_tag.to_upper():
		"FAKTA":
			return COLOR_TAG_FAKTA
		"TRADISI":
			return COLOR_TAG_TRADISI
		"FIKSI GAME":
			return COLOR_TAG_FIKSI
		_:
			return COLOR_DARK_BROWN


func create_panel_style(
	bg_color: Color = COLOR_PANEL_DARK,
	border_color: Color = COLOR_GOLD,
	corner_radius: int = 10,
	border_width: int = 2,
	padding: int = 14
) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg_color
	sb.border_color = border_color
	sb.set_border_width_all(border_width)
	sb.set_corner_radius_all(corner_radius)
	sb.content_margin_left = padding
	sb.content_margin_right = padding
	sb.content_margin_top = padding
	sb.content_margin_bottom = padding
	return sb


func create_button_style(bg_color: Color, border_color: Color = COLOR_GOLD) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg_color
	sb.border_color = border_color
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(8)
	sb.content_margin_left = 16
	sb.content_margin_right = 16
	sb.content_margin_top = 10
	sb.content_margin_bottom = 10
	return sb


func create_badge_style(source_tag: String) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = get_tag_color(source_tag)
	sb.border_color = COLOR_CREAM
	sb.set_border_width_all(1)
	sb.set_corner_radius_all(6)
	sb.content_margin_left = 10
	sb.content_margin_right = 10
	sb.content_margin_top = 3
	sb.content_margin_bottom = 3
	return sb


func build_theme() -> Theme:
	if _cached_theme != null:
		return _cached_theme

	var theme := Theme.new()
	theme.default_font_size = 16

	theme.set_color("font_color", "Label", COLOR_CREAM)
	theme.set_color("default_color", "RichTextLabel", COLOR_CREAM)

	theme.set_stylebox("panel", "PanelContainer", create_panel_style(COLOR_PANEL_DARK, COLOR_GOLD, 10, 2, 14))
	theme.set_stylebox("panel", "Panel", create_panel_style(COLOR_PANEL_DARK, COLOR_GOLD, 10, 2, 12))

	theme.set_stylebox("normal", "Button", create_button_style(COLOR_TERRACOTTA, COLOR_GOLD))
	theme.set_stylebox("hover", "Button", create_button_style(COLOR_TERRACOTTA.lightened(0.14), COLOR_CREAM))
	theme.set_stylebox("pressed", "Button", create_button_style(COLOR_TERRACOTTA_DARK, COLOR_GOLD))
	theme.set_stylebox("disabled", "Button", create_button_style(Color("#4E3C33"), Color("#786557")))
	theme.set_color("font_color", "Button", COLOR_CREAM)
	theme.set_color("font_hover_color", "Button", Color.WHITE)
	theme.set_color("font_pressed_color", "Button", COLOR_GOLD)
	theme.set_color("font_disabled_color", "Button", Color("#A8988A"))

	_cached_theme = theme
	return theme
