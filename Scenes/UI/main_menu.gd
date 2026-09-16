extends Control
"""
Claude me avisó de cómo conectar scenes entre ellas, pero hay una cosa que te dejo aquí y es 
que hay que agregar un par de variables globales para que el timer que escojás aquí se mestre en la UI
y básicamente dice así:
	'Ve a Project > Project Settings > Autoload y agrega un script nuevo (ej. Global.gd) con variables: 
	nombre_usuario, dificultad_bot, modo, bando_maya, tiempo_segundos. Sirve para pasar datos entre escenas, 
	ya que al cambiar de escena se pierden las referencias directas.
	ss
	En main_menu.gd, conecta tus propias señales a funciones que escriban en Global y cambien de escena: 
	configuracion_actualizada.connect(func(n, d): Global.nombre_usuario = n; 
	Global.dificultad_bot = d) partida_iniciada.connect(func(modo, bando, seg): 
	Global.modo = modo Global.bando_maya = bando Global.tiempo_segundos = seg get_tree().change_scene_to_file("res://Game.tscn") )' - Claude

"""


# ─────────────────────────────────────────────
#  SEÑALES (conectar desde la escena que instancie este menú)
# ─────────────────────────────────────────────
signal configuracion_actualizada(nombre: String, dificultad: int, piezas_maya: bool)
signal partida_iniciada(modo: String, bando_maya: bool, tiempo_segundos: int)

# ─────────────────────────────────────────────
#  COLORES DEL TEMA (mismos que game_ui.gd + acentos mayas)
# ─────────────────────────────────────────────
const COLOR_FONDO_PANEL := Color(0.24, 0.10, 0.00, 1.0)
const COLOR_BORDE_PANEL := Color(0.42, 0.23, 0.06, 1.0)
const COLOR_BORDE_AFND  := Color(0.22, 0.53, 0.19, 1.0)
const COLOR_TEXTO       := Color(0.91, 0.78, 0.48, 1.0)
const COLOR_TEXTO_MUTED := Color(0.63, 0.47, 0.25, 1.0)
const COLOR_MAYA        := Color(0.29, 0.54, 0.19, 1.0)
const COLOR_SPAIN       := Color(0.75, 0.22, 0.17, 1.0)
const COLOR_DORADO      := Color(0.85, 0.65, 0.13, 1.0)
const COLOR_OVERLAY     := Color(0.04, 0.02, 0.0, 0.82)

# ─────────────────────────────────────────────
#  ESTADO
# ─────────────────────────────────────────────
var nombre_usuario   := "Jugador"
var dificultad_bot   := 1          # 0 Fácil · 1 Medio · 2 Difícil
var piezas_estilo_maya := true     # true = piezas Maya · false = piezas clásicas
var modo_seleccionado := "bot"     # "bot" | "1v1"
var bando_maya        := true
var minutos_partida   := 10
var tiempo_segundos   := 600

# refs
var fondo: TextureRect
var input_nombre: LineEdit
var switch_piezas: Button
var pills_dificultad: Array[Button] = []
var pills_modo: Array[Button] = []
var pills_bando: Array[Button] = []
var pills_tiempo: Array[Button] = []
var btn_comenzar: Button

var overlay_opciones: Control
var overlay_jugar: Control
var panel_paso1: Control
var panel_paso2: Control

# ─────────────────────────────────────────────
#  ENTRADA PRINCIPAL
# ─────────────────────────────────────────────
func _ready() -> void:
	anchor_right  = 1.0
	anchor_bottom = 1.0

	_crear_fondo()
	_crear_contenido_principal()
	_crear_popup_opciones()
	_crear_popup_jugar()

# ─────────────────────────────────────────────
#  FONDO (dejar espacio para imagen)
# ─────────────────────────────────────────────
func _crear_fondo() -> void:
	fondo = TextureRect.new()
	fondo.anchor_right  = 1.0
	fondo.anchor_bottom = 1.0
	fondo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	fondo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	fondo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fondo.texture = preload("res://Scenes/UI/Gemini_Generated_Image_m0ymzcm0ymzcm0ym.jpg")
	add_child(fondo)

	# Velo oscuro para que el texto siempre sea legible sobre la imagen
	var velo := ColorRect.new()
	velo.anchor_right  = 1.0
	velo.anchor_bottom = 1.0
	velo.color = Color(0.02, 0.01, 0.0, 0.45)
	velo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(velo)

# ─────────────────────────────────────────────
#  HELPERS DE ESTILO (mismos que game_ui.gd)
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
		color_texto: Color = COLOR_TEXTO_MUTED, tam_fuente: int = 12) -> Button:
	var b := Button.new()
	b.text = texto
	b.clip_contents = false
	b.add_theme_color_override("font_color", color_texto)
	b.add_theme_font_size_override("font_size", tam_fuente)
	var normal := _estilo_transparente(20, color_borde, 1)
	normal.content_margin_left   = 14
	normal.content_margin_right  = 14
	normal.content_margin_top    = 8
	normal.content_margin_bottom = 8
	b.add_theme_stylebox_override("normal",  normal)
	b.add_theme_stylebox_override("hover",   _estilo_panel(20, COLOR_BORDE_PANEL * 0.5, color_borde, 1))
	b.add_theme_stylebox_override("pressed", _estilo_panel(20, COLOR_BORDE_PANEL * 0.7, color_borde, 1))
	b.add_theme_stylebox_override("focus",   _estilo_transparente(20, color_borde, 1))
	return b

# Botón grande estilo "estela maya" para el menú principal
func _boton_menu(texto: String, color_borde: Color = COLOR_DORADO) -> Button:
	var b := Button.new()
	b.text = texto
	b.custom_minimum_size = Vector2(240, 0)
	b.add_theme_color_override("font_color", COLOR_TEXTO)
	b.add_theme_font_size_override("font_size", 16)
	var normal := _estilo_panel(16, COLOR_FONDO_PANEL, color_borde, 2)
	normal.content_margin_top    = 16
	normal.content_margin_bottom = 16
	b.add_theme_stylebox_override("normal",  normal)
	b.add_theme_stylebox_override("hover",   _estilo_panel(16, COLOR_FONDO_PANEL * 1.4, color_borde, 2))
	b.add_theme_stylebox_override("pressed", _estilo_panel(16, COLOR_FONDO_PANEL * 0.8, color_borde, 2))
	b.add_theme_stylebox_override("focus",   _estilo_panel(16, COLOR_FONDO_PANEL, color_borde, 2))
	return b

func _separador_horizontal() -> HSeparator:
	var sep := HSeparator.new()
	sep.add_theme_color_override("color", COLOR_BORDE_PANEL)
	return sep

# marca visual de selección tipo "pill" (usado en dificultad / modo / bando / tiempo)
func _actualizar_seleccion(botones: Array[Button], idx_activo: int,
		color_activo: Color = COLOR_DORADO) -> void:
	for i in botones.size():
		var b := botones[i]
		var activo := i == idx_activo
		var borde := color_activo if activo else COLOR_BORDE_PANEL
		var s := _estilo_transparente(20, borde, 2 if activo else 1)
		s.content_margin_left = 14; s.content_margin_right  = 14
		s.content_margin_top  = 8;  s.content_margin_bottom = 8
		b.add_theme_stylebox_override("normal", s)
		b.add_theme_color_override("font_color", color_activo if activo else COLOR_TEXTO_MUTED)

# ─────────────────────────────────────────────
#  CONTENIDO PRINCIPAL (título + botones Jugar / Opciones)
# ─────────────────────────────────────────────
const DESPLAZAMIENTO_VERTICAL_MENU := -100  # negativo = sube el bloque · positivo = lo baja

func _crear_contenido_principal() -> void:
	var centro := CenterContainer.new()
	centro.anchor_right  = 1.0
	centro.anchor_bottom = 1.0
	centro.offset_top    = DESPLAZAMIENTO_VERTICAL_MENU
	centro.offset_bottom = DESPLAZAMIENTO_VERTICAL_MENU
	add_child(centro)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 28)
	centro.add_child(vbox)

	# Bloque de título tipo "estela"
	var panel_titulo := PanelContainer.new()
	panel_titulo.add_theme_stylebox_override("panel", _estilo_panel(20, COLOR_FONDO_PANEL, COLOR_DORADO, 2))
	var margin_t := MarginContainer.new()
	margin_t.add_theme_constant_override("margin_left",   32)
	margin_t.add_theme_constant_override("margin_right",  32)
	margin_t.add_theme_constant_override("margin_top",    20)
	margin_t.add_theme_constant_override("margin_bottom", 20)
	panel_titulo.add_child(margin_t)

	var vbox_t := VBoxContainer.new()
	vbox_t.add_theme_constant_override("separation", 4)
	margin_t.add_child(vbox_t)

	var titulo := _label("KAB'AWIL CHESS", 26, COLOR_DORADO)
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox_t.add_child(titulo)

	var subtitulo := _label("✧ La Invasión hacia América en un tablero ✧", 12, COLOR_TEXTO_MUTED)
	subtitulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox_t.add_child(subtitulo)

	vbox.add_child(panel_titulo)

	# Botones principales
	var vbox_botones := VBoxContainer.new()
	vbox_botones.add_theme_constant_override("separation", 14)
	vbox_botones.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_child(vbox_botones)

	var btn_jugar := _boton_menu("⚔  Jugar", COLOR_MAYA)
	btn_jugar.pressed.connect(_on_abrir_jugar)
	vbox_botones.add_child(btn_jugar)

	var btn_opciones := _boton_menu("⚙  Opciones", COLOR_BORDE_PANEL)
	btn_opciones.pressed.connect(_on_abrir_opciones)
	vbox_botones.add_child(btn_opciones)

# ─────────────────────────────────────────────
#  OVERLAY BASE PARA POPUPS
# ─────────────────────────────────────────────
func _crear_overlay() -> Control:
	var overlay := Control.new()
	overlay.anchor_right  = 1.0
	overlay.anchor_bottom = 1.0
	overlay.visible = false

	var fondo_oscuro := ColorRect.new()
	fondo_oscuro.anchor_right  = 1.0
	fondo_oscuro.anchor_bottom = 1.0
	fondo_oscuro.color = COLOR_OVERLAY
	overlay.add_child(fondo_oscuro)

	add_child(overlay)
	return overlay

func _abrir(overlay: Control) -> void:
	overlay.modulate.a = 0.0
	overlay.visible = true
	var t := create_tween()
	t.tween_property(overlay, "modulate:a", 1.0, 0.15)

func _cerrar(overlay: Control) -> void:
	var t := create_tween()
	t.tween_property(overlay, "modulate:a", 0.0, 0.12)
	t.tween_callback(func(): overlay.visible = false)

# ─────────────────────────────────────────────
#  POPUP · OPCIONES
# ─────────────────────────────────────────────
func _crear_popup_opciones() -> void:
	overlay_opciones = _crear_overlay()

	var centro := CenterContainer.new()
	centro.anchor_right  = 1.0
	centro.anchor_bottom = 1.0
	overlay_opciones.add_child(centro)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(340, 0)
	panel.add_theme_stylebox_override("panel", _estilo_panel(20, COLOR_FONDO_PANEL, COLOR_DORADO, 2))
	centro.add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left",   22)
	margin.add_theme_constant_override("margin_right",  22)
	margin.add_theme_constant_override("margin_top",    20)
	margin.add_theme_constant_override("margin_bottom", 20)
	panel.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 14)
	margin.add_child(vbox)

	vbox.add_child(_label("Configuración", 16, COLOR_DORADO))
	vbox.add_child(_separador_horizontal())

	vbox.add_child(_label("Nombre de usuario", 11, COLOR_TEXTO_MUTED))
	input_nombre = LineEdit.new()
	input_nombre.text = nombre_usuario
	input_nombre.placeholder_text = "Escribe tu nombre..."
	input_nombre.add_theme_stylebox_override("normal", _estilo_transparente(12, COLOR_BORDE_PANEL, 1))
	input_nombre.add_theme_stylebox_override("focus",  _estilo_transparente(12, COLOR_DORADO, 1))
	input_nombre.add_theme_color_override("font_color", COLOR_TEXTO)
	vbox.add_child(input_nombre)

	vbox.add_child(_label("Dificultad del Bot", 11, COLOR_TEXTO_MUTED))
	var hbox_dif := HBoxContainer.new()
	hbox_dif.add_theme_constant_override("separation", 8)
	vbox.add_child(hbox_dif)

	pills_dificultad.clear()
	for etiqueta in ["Fácil", "Medio", "Difícil"]:
		var b := _boton_pill(etiqueta)
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var idx := pills_dificultad.size()
		b.pressed.connect(func(): dificultad_bot = idx; _actualizar_seleccion(pills_dificultad, idx))
		hbox_dif.add_child(b)
		pills_dificultad.append(b)
	_actualizar_seleccion(pills_dificultad, dificultad_bot)

	vbox.add_child(_separador_horizontal())

	vbox.add_child(_label("Estilo de piezas", 11, COLOR_TEXTO_MUTED))
	switch_piezas = _crear_switch_piezas()
	vbox.add_child(switch_piezas)

	vbox.add_child(_separador_horizontal())

	var hbox_botones := HBoxContainer.new()
	hbox_botones.add_theme_constant_override("separation", 10)
	vbox.add_child(hbox_botones)

	var btn_cancelar := _boton_pill("Cancelar")
	btn_cancelar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn_cancelar.pressed.connect(func(): _cerrar(overlay_opciones))
	hbox_botones.add_child(btn_cancelar)

	var btn_guardar := _boton_pill("Guardar", COLOR_MAYA, COLOR_MAYA)
	btn_guardar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn_guardar.pressed.connect(_on_guardar_opciones)
	hbox_botones.add_child(btn_guardar)

func _on_abrir_opciones() -> void:
	input_nombre.text = nombre_usuario
	_actualizar_seleccion(pills_dificultad, dificultad_bot)
	switch_piezas.button_pressed = piezas_estilo_maya
	_actualizar_estilo_switch(switch_piezas)
	_abrir(overlay_opciones)

func _on_guardar_opciones() -> void:
	nombre_usuario = input_nombre.text.strip_edges()
	if nombre_usuario == "":
		nombre_usuario = "Jugador"
	configuracion_actualizada.emit(nombre_usuario, dificultad_bot, piezas_estilo_maya)
	_cerrar(overlay_opciones)

# Switch de dos estados (Piezas Mayas / Piezas Clásicas)
func _crear_switch_piezas() -> Button:
	var b := Button.new()
	b.toggle_mode = true
	b.button_pressed = piezas_estilo_maya
	b.clip_contents = false
	b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	b.add_theme_font_size_override("font_size", 13)
	b.toggled.connect(func(activado: bool):
		piezas_estilo_maya = activado
		_actualizar_estilo_switch(b)
	)
	_actualizar_estilo_switch(b)
	return b

func _actualizar_estilo_switch(b: Button) -> void:
	var color := COLOR_MAYA if piezas_estilo_maya else COLOR_TEXTO_MUTED
	b.text = "🌿  Piezas Mayas" if piezas_estilo_maya else "♟  Piezas Clásicas"
	b.add_theme_color_override("font_color", color)
	var estilo := _estilo_transparente(16, color, 2)
	estilo.content_margin_left   = 14
	estilo.content_margin_right  = 14
	estilo.content_margin_top    = 10
	estilo.content_margin_bottom = 10
	b.add_theme_stylebox_override("normal",  estilo)
	b.add_theme_stylebox_override("hover",   estilo)
	b.add_theme_stylebox_override("pressed", estilo)
	b.add_theme_stylebox_override("focus",   estilo)

# ─────────────────────────────────────────────
#  POPUP · JUGAR (2 pasos con transición)
# ─────────────────────────────────────────────
func _crear_popup_jugar() -> void:
	overlay_jugar = _crear_overlay()

	var centro := CenterContainer.new()
	centro.anchor_right  = 1.0
	centro.anchor_bottom = 1.0
	overlay_jugar.add_child(centro)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(380, 0)
	panel.add_theme_stylebox_override("panel", _estilo_panel(20, COLOR_FONDO_PANEL, COLOR_DORADO, 2))
	centro.add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left",   22)
	margin.add_theme_constant_override("margin_right",  22)
	margin.add_theme_constant_override("margin_top",    20)
	margin.add_theme_constant_override("margin_bottom", 20)
	panel.add_child(margin)

	var stack := VBoxContainer.new()
	margin.add_child(stack)

	panel_paso1 = _crear_paso1_jugar()
	panel_paso2 = _crear_paso2_jugar()
	stack.add_child(panel_paso1)
	stack.add_child(panel_paso2)
	panel_paso2.visible = false

func _crear_paso1_jugar() -> VBoxContainer:
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 14)

	vbox.add_child(_label("Nueva Partida", 16, COLOR_DORADO))
	vbox.add_child(_separador_horizontal())
	vbox.add_child(_label("¿Cómo quieres jugar?", 11, COLOR_TEXTO_MUTED))

	var btn_1v1 := _boton_menu("👥  1 vs 1 (local)", COLOR_BORDE_PANEL)
	btn_1v1.pressed.connect(func(): modo_seleccionado = "1v1"; _ir_a_paso2())
	vbox.add_child(btn_1v1)

	var btn_bot := _boton_menu("🤖  Contra el Bot", COLOR_MAYA)
	btn_bot.pressed.connect(func(): modo_seleccionado = "bot"; _ir_a_paso2())
	vbox.add_child(btn_bot)

	var btn_cerrar := _boton_pill("Cancelar")
	btn_cerrar.pressed.connect(func(): _cerrar(overlay_jugar))
	vbox.add_child(btn_cerrar)

	return vbox

func _crear_paso2_jugar() -> VBoxContainer:
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 14)

	var hbox_top := HBoxContainer.new()
	var btn_atras := _boton_pill("← Atrás")
	btn_atras.pressed.connect(_ir_a_paso1)
	hbox_top.add_child(btn_atras)
	vbox.add_child(hbox_top)

	vbox.add_child(_label("Elige tu bando", 11, COLOR_TEXTO_MUTED))
	var hbox_bando := HBoxContainer.new()
	hbox_bando.add_theme_constant_override("separation", 10)
	vbox.add_child(hbox_bando)

	pills_bando.clear()
	var btn_maya := _boton_pill("● Mayas", COLOR_MAYA, COLOR_MAYA, 13)
	btn_maya.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn_maya.pressed.connect(func(): bando_maya = false; _actualizar_seleccion(pills_bando, 0, COLOR_MAYA))
	hbox_bando.add_child(btn_maya)
	pills_bando.append(btn_maya)

	var btn_spain := _boton_pill("● Reino de España", COLOR_SPAIN, COLOR_SPAIN, 13)
	btn_spain.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn_spain.pressed.connect(func(): bando_maya = true; _actualizar_seleccion(pills_bando, 1, COLOR_SPAIN))
	hbox_bando.add_child(btn_spain)
	pills_bando.append(btn_spain)

	vbox.add_child(_separador_horizontal())

	vbox.add_child(_label("Tiempo de partida", 11, COLOR_TEXTO_MUTED))
	var grid_tiempo := GridContainer.new()
	grid_tiempo.columns = 3
	grid_tiempo.add_theme_constant_override("h_separation", 8)
	grid_tiempo.add_theme_constant_override("v_separation", 8)
	vbox.add_child(grid_tiempo)

	pills_tiempo.clear()
	var opciones_tiempo := [3, 5, 10, 15, 30, 60]
	for minutos in opciones_tiempo:
		var b := _boton_pill("%d min" % minutos)
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var idx := pills_tiempo.size()
		b.pressed.connect(func(): minutos_partida = minutos; _actualizar_seleccion(pills_tiempo, idx))
		grid_tiempo.add_child(b)
		pills_tiempo.append(b)

	vbox.add_child(_separador_horizontal())

	btn_comenzar = _boton_menu("⚔  Comenzar Partida", COLOR_DORADO)
	btn_comenzar.pressed.connect(_on_comenzar_partida)
	vbox.add_child(btn_comenzar)

	return vbox

func _ir_a_paso2() -> void:
	_actualizar_seleccion(pills_bando, 0 if bando_maya else 1, COLOR_MAYA if bando_maya else COLOR_SPAIN)
	_actualizar_seleccion(pills_tiempo, [3, 5, 10, 15, 30, 60].find(minutos_partida))
	panel_paso1.visible = false
	panel_paso2.visible = true
	panel_paso2.modulate.a = 0.0
	var t := create_tween()
	t.tween_property(panel_paso2, "modulate:a", 1.0, 0.15)

func _ir_a_paso1() -> void:
	panel_paso2.visible = false
	panel_paso1.visible = true
	panel_paso1.modulate.a = 0.0
	var t := create_tween()
	t.tween_property(panel_paso1, "modulate:a", 1.0, 0.15)

func _on_abrir_jugar() -> void:
	_ir_a_paso1()
	_abrir(overlay_jugar)

func _on_comenzar_partida() -> void:
	tiempo_segundos = minutos_partida * 60
	partida_iniciada.emit(modo_seleccionado, bando_maya, tiempo_segundos)
	_cerrar(overlay_jugar)
	save_info()
	utils.transition_scene('Scenes/PlayScene.tscn')

func save_info() -> void:
	if modo_seleccionado == "bot":
		GlobalManager.mode = "bot"
		GlobalManager.player2_name = "Alvarbot-5000"
		GlobalManager.player1_name = nombre_usuario
		GlobalManager.bot_difficulty = dificultad_bot  # 0 Fácil · 1 Medio · 2 Difícil
	else:
		GlobalManager.mode = "1vs1" 
		GlobalManager.player2_name = "Player 2"
		GlobalManager.player1_name = nombre_usuario
		GlobalManager.bot_difficulty = -1
		
	GlobalManager.time = tiempo_segundos
	GlobalManager.style = int(piezas_estilo_maya) # 1 = piezas Maya | 0 = piezas clásicas
	GlobalManager.side = int(bando_maya) # 1 negras/colonizador | 0 blancas/Tropa
	
	print(GlobalManager.player1_name)

"""
var piezas_estilo_maya := true     # true = piezas Maya · false = piezas clásicas
var modo_seleccionado := "bot"     # "bot" | "1v1"
var bando_maya        := true
var minutos_partida   := 10
var tiempo_segundos   := 600
"""
