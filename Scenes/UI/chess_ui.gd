extends Control

# ─────────────────────────────────────────────
#  COLORES DEL TEMA
# ─────────────────────────────────────────────
const COLOR_FONDO_PANEL   := Color(0.24, 0.10, 0.00, 1.0)
const COLOR_BORDE_PANEL   := Color(0.42, 0.23, 0.06, 1.0)
const COLOR_BORDE_AFND    := Color(0.22, 0.53, 0.19, 1.0)
const COLOR_TEXTO         := Color(0.91, 0.78, 0.48, 1.0)
const COLOR_TEXTO_MUTED   := Color(0.63, 0.47, 0.25, 1.0)
const COLOR_MAYA          := Color(0.29, 0.54, 0.19, 1.0)
const COLOR_SPAIN         := Color(0.75, 0.22, 0.17, 1.0)

# ─────────────────────────────────────────────
#  ESTADO
# ─────────────────────────────────────────────
var turno_maya   := true
var numero_turno := 1
var capturadas_maya  : Array[String] = []
var capturadas_spain : Array[String] = []

# tiempo de partida (viene del main menu)
var tiempo_restante_maya  := 600
var tiempo_restante_spain := 600

var label_turno         : Label
var label_caps_maya     : Label
var label_caps_spain    : Label
var label_tiempo_maya   : Label
var label_tiempo_spain  : Label
var pill_turno_maya  : Button
var pill_turno_spain : Button

# ─────────────────────────────────────────────
#  ENTRADA PRINCIPAL
# ─────────────────────────────────────────────
func _ready() -> void:
	anchor_right  = 1.0
	anchor_bottom = 1.0

	# Contenedor raíz que ocupa toda la pantalla
	var margin := MarginContainer.new()
	margin.anchor_right  = 1.0
	margin.anchor_bottom = 1.0
	margin.add_theme_constant_override("margin_left",   14)
	margin.add_theme_constant_override("margin_right",  14)
	margin.add_theme_constant_override("margin_top",    16)
	margin.add_theme_constant_override("margin_bottom", 16)
	add_child(margin)

	# VBox principal — ocupa todo el alto disponible
	var vbox := VBoxContainer.new()
	vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_theme_constant_override("separation", 10)
	margin.add_child(vbox)

	# ── Secciones superiores ──
	vbox.add_child(_crear_topbar())
	vbox.add_child(_crear_resumen())

	# ── Spacer: empuja las secciones inferiores hacia abajo ──
	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(spacer)

	# ── Secciones inferiores ──
	vbox.add_child(_crear_capturadas())
	vbox.add_child(_crear_tabla_afnd())

# ─────────────────────────────────────────────
#  HELPERS DE ESTILO
# ─────────────────────────────────────────────
func _estilo_panel(radio: int = 18, color_fondo: Color = COLOR_FONDO_PANEL,
		color_borde: Color = COLOR_BORDE_PANEL, grosor: int = 2) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color     = color_fondo
	s.border_color = color_borde
	s.set_border_width_all(grosor)
	s.set_corner_radius_all(radio)
	s.set_content_margin_all(0)
	return s

func _estilo_transparente(radio: int = 18, color_borde: Color = COLOR_BORDE_PANEL,
		grosor: int = 1) -> StyleBoxFlat:
	return _estilo_panel(radio, Color(0, 0, 0, 0), color_borde, grosor)

func _label(texto: String, size: int = 13, color: Color = COLOR_TEXTO) -> Label:
	var l := Label.new()
	l.text = texto
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	l.clip_contents = false
	l.autowrap_mode = TextServer.AUTOWRAP_OFF
	l.text_overrun_behavior = TextServer.OVERRUN_NO_TRIMMING
	return l

func _boton_pill(texto: String, color_borde: Color = COLOR_BORDE_PANEL,
		color_texto: Color = COLOR_TEXTO_MUTED) -> Button:
	var b := Button.new()
	b.text = texto
	b.clip_contents = false
	b.add_theme_color_override("font_color", color_texto)
	b.add_theme_font_size_override("font_size", 12)
	var normal := _estilo_transparente(20, color_borde, 1)
	normal.content_margin_left   = 14
	normal.content_margin_right  = 14
	normal.content_margin_top    = 6
	normal.content_margin_bottom = 6
	b.add_theme_stylebox_override("normal",  normal)
	b.add_theme_stylebox_override("hover",   _estilo_panel(20, COLOR_BORDE_PANEL * 0.5, color_borde, 1))
	b.add_theme_stylebox_override("pressed", _estilo_panel(20, COLOR_BORDE_PANEL * 0.7, color_borde, 1))
	b.add_theme_stylebox_override("focus",   _estilo_transparente(20, color_borde, 1))
	return b

# ─────────────────────────────────────────────
#  SECCIÓN 1 — TOPBAR
# ─────────────────────────────────────────────
func _crear_topbar() -> PanelContainer:
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _estilo_panel(20))

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left",   16)
	margin.add_theme_constant_override("margin_right",  12)
	margin.add_theme_constant_override("margin_top",    12)
	margin.add_theme_constant_override("margin_bottom", 12)
	panel.add_child(margin)

	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 8)
	margin.add_child(hbox)

	var titulo := _label("Kab'awil Chess", 15, COLOR_TEXTO)
	titulo.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(titulo)

	var btn_opciones := _boton_pill("⚙ Opciones")
	btn_opciones.pressed.connect(_on_opciones)
	hbox.add_child(btn_opciones)

	return panel

# ─────────────────────────────────────────────
#  SECCIÓN 2 — RESUMEN
# ─────────────────────────────────────────────
func _crear_resumen() -> PanelContainer:
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _estilo_panel(20))

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left",   16)
	margin.add_theme_constant_override("margin_right",  16)
	margin.add_theme_constant_override("margin_top",    12)
	margin.add_theme_constant_override("margin_bottom", 12)
	panel.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	margin.add_child(vbox)

	label_turno = _label("Partida en curso · Turno 1", 11, COLOR_TEXTO_MUTED)
	label_turno.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(label_turno)

	var hbox_p := HBoxContainer.new()
	hbox_p.add_theme_constant_override("separation", 8)
	vbox.add_child(hbox_p)

	var pill_maya := _crear_player_pill("Mayas", _formato_tiempo(tiempo_restante_maya), COLOR_MAYA, true, true)
	pill_maya.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox_p.add_child(pill_maya)

	var vs := _label("vs", 10, COLOR_TEXTO_MUTED)
	vs.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	hbox_p.add_child(vs)

	var pill_spain := _crear_player_pill("Reino de España", _formato_tiempo(tiempo_restante_spain), COLOR_SPAIN, false, false)
	pill_spain.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox_p.add_child(pill_spain)

	var hbox_t := HBoxContainer.new()
	hbox_t.add_theme_constant_override("separation", 10)
	vbox.add_child(hbox_t)

	pill_turno_maya = _boton_pill("● Mayas", COLOR_MAYA, COLOR_MAYA)
	pill_turno_maya.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	pill_turno_maya.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hbox_t.add_child(pill_turno_maya)

	pill_turno_spain = _boton_pill("● Reino de España", COLOR_BORDE_PANEL, COLOR_TEXTO_MUTED)
	pill_turno_spain.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	pill_turno_spain.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hbox_t.add_child(pill_turno_spain)
	return panel

func _crear_player_pill(nombre: String, tiempo: String,
		color_dot: Color, es_activo: bool, es_maya: bool) -> PanelContainer:
	var panel := PanelContainer.new()
	var borde := color_dot if es_activo else COLOR_BORDE_PANEL
	panel.add_theme_stylebox_override("panel", _estilo_transparente(16, borde, 1))

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left",   10)
	margin.add_theme_constant_override("margin_right",  10)
	margin.add_theme_constant_override("margin_top",    7)
	margin.add_theme_constant_override("margin_bottom", 7)
	panel.add_child(margin)

	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 6)
	margin.add_child(hbox)

	var dot_wrap := CenterContainer.new()
	dot_wrap.custom_minimum_size = Vector2(10, 0)
	var dot := ColorRect.new()
	dot.color = color_dot
	dot.custom_minimum_size = Vector2(8, 8)
	dot_wrap.add_child(dot)
	hbox.add_child(dot_wrap)

	var lbl_n := _label(nombre, 12, COLOR_TEXTO if es_activo else COLOR_TEXTO_MUTED)
	lbl_n.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(lbl_n)

	var lbl_tiempo := _label(tiempo, 11, COLOR_TEXTO_MUTED)
	hbox.add_child(lbl_tiempo)
	if es_maya:
		label_tiempo_maya = lbl_tiempo
	else:
		label_tiempo_spain = lbl_tiempo

	return panel

# ─────────────────────────────────────────────
#  SECCIÓN 3 — PIEZAS CAPTURADAS
# ─────────────────────────────────────────────
func _crear_capturadas() -> PanelContainer:
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _estilo_panel(20))

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left",   16)
	margin.add_theme_constant_override("margin_right",  16)
	margin.add_theme_constant_override("margin_top",    10)
	margin.add_theme_constant_override("margin_bottom", 10)
	panel.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)
	margin.add_child(vbox)

	vbox.add_child(_label("Piezas capturadas", 11, COLOR_TEXTO_MUTED))

	# Fila Maya
	var fila_maya := HBoxContainer.new()
	fila_maya.add_theme_constant_override("separation", 8)
	vbox.add_child(fila_maya)

	var dw_m := CenterContainer.new()
	dw_m.custom_minimum_size = Vector2(10, 16)
	var dot_m := ColorRect.new()
	dot_m.color = COLOR_MAYA
	dot_m.custom_minimum_size = Vector2(8, 8)
	dw_m.add_child(dot_m)
	fila_maya.add_child(dw_m)
	fila_maya.add_child(_label("Mayas:", 12, COLOR_TEXTO_MUTED))
	label_caps_maya = _label("—", 13, COLOR_TEXTO)
	label_caps_maya.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	fila_maya.add_child(label_caps_maya)

	var sep := HSeparator.new()
	sep.add_theme_color_override("color", COLOR_BORDE_PANEL)
	vbox.add_child(sep)

	# Fila España
	var fila_spain := HBoxContainer.new()
	fila_spain.add_theme_constant_override("separation", 8)
	vbox.add_child(fila_spain)

	var dw_s := CenterContainer.new()
	dw_s.custom_minimum_size = Vector2(10, 16)
	var dot_s := ColorRect.new()
	dot_s.color = COLOR_SPAIN
	dot_s.custom_minimum_size = Vector2(8, 8)
	dw_s.add_child(dot_s)
	fila_spain.add_child(dw_s)
	fila_spain.add_child(_label("España:", 12, COLOR_TEXTO_MUTED))
	label_caps_spain = _label("—", 13, COLOR_TEXTO)
	label_caps_spain.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	fila_spain.add_child(label_caps_spain)

	return panel

# ─────────────────────────────────────────────
#  SECCIÓN 4 — TABLA AFND
# ─────────────────────────────────────────────
func _crear_tabla_afnd() -> PanelContainer:
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _estilo_panel(20, COLOR_FONDO_PANEL, COLOR_BORDE_AFND, 2))

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left",   12)
	margin.add_theme_constant_override("margin_right",  12)
	margin.add_theme_constant_override("margin_top",    10)
	margin.add_theme_constant_override("margin_bottom", 10)
	panel.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 8)
	margin.add_child(vbox)

	vbox.add_child(_label("Tabla AFND", 12, COLOR_BORDE_AFND))

	# Botones apilados verticalmente
	var btn_elegir := _crear_boton_afnd("Elegir pieza", COLOR_BORDE_PANEL, COLOR_TEXTO)
	vbox.add_child(btn_elegir)

	var btn_diagrama := _crear_boton_afnd("Mostrar Diagrama", COLOR_BORDE_AFND, COLOR_BORDE_AFND)
	vbox.add_child(btn_diagrama)

	btn_elegir.pressed.connect(_on_elegir_pieza)
	btn_diagrama.pressed.connect(_on_mostrar_diagrama)

	return panel

func _crear_boton_afnd(texto: String, color_borde: Color, color_texto: Color) -> Button:
	var b := Button.new()
	b.text = texto
	b.clip_contents = false
	b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	b.add_theme_color_override("font_color", color_texto)
	b.add_theme_font_size_override("font_size", 13)

	var normal := _estilo_transparente(14, color_borde, 2)
	normal.content_margin_left   = 12
	normal.content_margin_right  = 12
	normal.content_margin_top    = 14
	normal.content_margin_bottom = 14
	b.add_theme_stylebox_override("normal",  normal)
	b.add_theme_stylebox_override("hover",   _estilo_panel(14, COLOR_FONDO_PANEL * 1.3, color_borde, 2))
	b.add_theme_stylebox_override("pressed", _estilo_panel(14, COLOR_FONDO_PANEL * 0.8, color_borde, 2))
	b.add_theme_stylebox_override("focus",   _estilo_transparente(14, color_borde, 2))
	return b

# ─────────────────────────────────────────────
#  ACTUALIZAR UI EN RUNTIME
# ─────────────────────────────────────────────
func actualizar_turno(es_maya: bool, turno: int) -> void:
	turno_maya   = es_maya
	numero_turno = turno
	if label_turno:
		label_turno.text = "Partida en curso · Turno %d" % numero_turno

	# Pill maya
	var s_maya := _estilo_transparente(20, COLOR_MAYA if turno_maya else COLOR_BORDE_PANEL, 1)
	s_maya.content_margin_left = 14; s_maya.content_margin_right  = 14
	s_maya.content_margin_top  = 6;  s_maya.content_margin_bottom = 6
	pill_turno_maya.add_theme_stylebox_override("normal", s_maya)
	pill_turno_maya.add_theme_color_override("font_color",
		COLOR_MAYA if turno_maya else COLOR_TEXTO_MUTED)

	# Pill españa
	var s_spain := _estilo_transparente(20, COLOR_SPAIN if !turno_maya else COLOR_BORDE_PANEL, 1)
	s_spain.content_margin_left = 14; s_spain.content_margin_right  = 14
	s_spain.content_margin_top  = 6;  s_spain.content_margin_bottom = 6
	pill_turno_spain.add_theme_stylebox_override("normal", s_spain)
	pill_turno_spain.add_theme_color_override("font_color",COLOR_SPAIN if !turno_maya else COLOR_TEXTO_MUTED)

func agregar_captura(pieza: String, capturada_por_maya: bool) -> void:
	if capturada_por_maya:
		capturadas_maya.append(pieza)
		if label_caps_maya:
			label_caps_maya.text = " ".join(capturadas_maya)
	else:
		capturadas_spain.append(pieza)
		if label_caps_spain:
			label_caps_spain.text = " ".join(capturadas_spain)

# ─────────────────────────────────────────────
#  TIEMPO DE PARTIDA (conexión con main_menu.gd)
# ─────────────────────────────────────────────
# Llamar tras instanciar esta escena, con la señal partida_iniciada del menú:
#   menu.partida_iniciada.connect(func(modo, bando_maya, segundos):
#       game_ui.establecer_tiempo_inicial(segundos)
#   )
func establecer_tiempo_inicial(segundos: int) -> void:
	tiempo_restante_maya  = segundos
	tiempo_restante_spain = segundos
	if label_tiempo_maya:
		label_tiempo_maya.text = _formato_tiempo(tiempo_restante_maya)
	if label_tiempo_spain:
		label_tiempo_spain.text = _formato_tiempo(tiempo_restante_spain)

func actualizar_tiempo(es_maya: bool, segundos: int) -> void:
	if es_maya:
		tiempo_restante_maya = segundos
		if label_tiempo_maya:
			label_tiempo_maya.text = _formato_tiempo(segundos)
	else:
		tiempo_restante_spain = segundos
		if label_tiempo_spain:
			label_tiempo_spain.text = _formato_tiempo(segundos)

func _formato_tiempo(segundos: int) -> String:
	return "%d:%02d" % [segundos / 60, segundos % 60]

# ─────────────────────────────────────────────
#  CALLBACKS
# ─────────────────────────────────────────────
func _on_opciones() -> void:
	print("Abrir opciones")

func _on_elegir_pieza() -> void:
	print("Elegir pieza")

func _on_mostrar_diagrama() -> void:
	print("Mostrar diagrama AFND")
