class_name ArrowPath
extends Node

const SOURCE_ID := 0      # "Origen" del atlas en el TileSet
const BOARD_SIZE := 8     # origin y dest deben cumplir 0 <= x, y < BOARD_SIZE
const NO_TILE := Vector2i(-1, -1)   # "tile aún no definido": se omite al dibujar
 
# Direcciones de avance (coordenadas de tilemap: +y hacia abajo)
const DIR_N  := Vector2i( 0, -1)
const DIR_NE := Vector2i( 1, -1)
const DIR_E  := Vector2i( 1,  0)
const DIR_SE := Vector2i( 1,  1)
const DIR_S  := Vector2i( 0,  1)
const DIR_SW := Vector2i(-1,  1)
const DIR_W  := Vector2i(-1,  0)
const DIR_NW := Vector2i(-1, -1)
 
# ── Cuerpos rectos: PENDIENTES (no existen en el atlas todavía) ──
# Rellena estas dos constantes cuando tengas el arte.
const STRAIGHT_H := NO_TILE   # cuerpo horizontal
const STRAIGHT_V := NO_TILE   # cuerpo vertical
 
# ── Cabezas de flecha (tile del destino), según la dirección de avance ──
const HEAD_TILES := {
	DIR_N:  Vector2i(0, 3),
	DIR_E:  Vector2i(1, 3),
	DIR_S:  Vector2i(1, 4),
	DIR_W:  Vector2i(0, 4),
	DIR_NE: Vector2i(5, 0),
	DIR_SW: Vector2i(3, 2),
	DIR_NW: Vector2i(6, 0),
	DIR_SE: Vector2i(8, 2),
}
 
# ── Cuerpo de la línea (tiles intermedios), según la dirección de avance ──
const BODY_TILES := {
	DIR_N:  STRAIGHT_V,
	DIR_S:  STRAIGHT_V,
	DIR_E:  STRAIGHT_H,
	DIR_W:  STRAIGHT_H,
	DIR_NE: Vector2i(4, 1),   # diagonal "/"
	DIR_SW: Vector2i(4, 1),
	DIR_NW: Vector2i(7, 1),   # diagonal "\"
	DIR_SE: Vector2i(7, 1),
}
 
# ── Tile de inicio (origen) por dirección. ──
# Si una dirección no está aquí, el origen usa el tile de BODY_TILES.
# Ejemplo: DIR_E: Vector2i(2, 3)
const ORIGIN_TILES := {}
 
# ── Tiles de giro para el caso en "L" ──
# Clave: Vector4i(dir_tramo1.x, dir_tramo1.y, dir_tramo2.x, dir_tramo2.y)
# Ejemplo (avanza al Este y luego gira al Sur): Vector4i(1, 0, 0, 1): Vector2i(x, y)
# Si un giro no está definido, se usa el cuerpo del primer tramo.
const BEND_TILES := {}
 
# ── Tiles extra de las diagonales (los que evitan que la línea salga cortada) ──
# Se colocan en las dos celdas que comparten la esquina entre dos celdas
# consecutivas de la diagonal: una por encima y otra por debajo de la línea.
# "/"  -> UPPER = arriba-izquierda, LOWER = abajo-derecha
# "\"  -> UPPER = arriba-derecha,   LOWER = abajo-izquierda
# (Equivalentes en tu atlas, por si prefieres otros: "/" (4,0)/(5,1) · "\" (8,1)/(7,2))
const SPILL_SLASH_UPPER := Vector2i(3, 1)
const SPILL_SLASH_LOWER := Vector2i(4, 2)
const SPILL_BACK_UPPER  := Vector2i(7, 0)
const SPILL_BACK_LOWER  := Vector2i(6, 1)
 
 
# ══════════════════════════════════════════════════════════════════
#  API PÚBLICA
# ══════════════════════════════════════════════════════════════════
 
static func clear_all(layer: TileMapLayer):
	layer.clear()

static func draw_arrow(origin: Vector2i, dest: Vector2i, layer: TileMapLayer) -> void:
	if layer == null:
		push_error("ArrowPath: el TileMapLayer es null.")
		return
	if not _in_board(origin) or not _in_board(dest):
		push_error("ArrowPath: origin %s y dest %s deben estar en [0, %d)." % [origin, dest, BOARD_SIZE])
		return
	if origin == dest:
		push_warning("ArrowPath: origin y dest son iguales, no hay nada que dibujar.")
		return
 
	var legs := _build_legs(dest - origin)
	var cursor := origin
	var prev_dir := Vector2i.ZERO
 
	for i in legs.size():
		var leg: Vector2i = legs[i]
		var dir := Vector2i(signi(leg.x), signi(leg.y))
		var steps := maxi(absi(leg.x), absi(leg.y))
 
		# Celdas del tramo, sin incluir la última (que es el inicio del siguiente
		# tramo o, en el último tramo, el destino).
		for s in steps:
			var tile: Vector2i
			if i == 0 and s == 0:
				tile = _origin_tile(dir)
			elif s == 0:
				tile = _bend_tile(prev_dir, dir)
			else:
				tile = BODY_TILES[dir]
			_put(layer, cursor + dir * s, tile)
 
		# Diagonal: tiles extra en cada esquina compartida (incluida la del destino).
		if dir.x != 0 and dir.y != 0:
			for s in steps:
				_put_diagonal_spill(layer, cursor + dir * s, dir)
 
		cursor += leg
		prev_dir = dir
 
	# El destino siempre termina como cabeza de flecha.
	_put(layer, dest, HEAD_TILES[prev_dir])
 
 
# ══════════════════════════════════════════════════════════════════
#  INTERNOS
# ══════════════════════════════════════════════════════════════════
 
static func _in_board(cell: Vector2i) -> bool:
	return cell.x >= 0 and cell.y >= 0 and cell.x < BOARD_SIZE and cell.y < BOARD_SIZE
 
 
## Divide el desplazamiento en tramos. Recto/diagonal -> 1 tramo; el resto -> 2 tramos rectos
## (primero el eje de mayor distancia).
static func _build_legs(delta: Vector2i) -> Array[Vector2i]:
	var legs: Array[Vector2i] = []
	var ax := absi(delta.x)
	var ay := absi(delta.y)
 
	if delta.x == 0 or delta.y == 0 or ax == ay:
		legs.append(delta)
		return legs
 
	var horizontal := Vector2i(delta.x, 0)
	var vertical := Vector2i(0, delta.y)
	if ax > ay:
		legs.append(horizontal)
		legs.append(vertical)
	else:
		legs.append(vertical)
		legs.append(horizontal)
	return legs
 
 
static func _origin_tile(dir: Vector2i) -> Vector2i:
	var tile: Vector2i = ORIGIN_TILES.get(dir, NO_TILE)
	return tile if tile != NO_TILE else BODY_TILES[dir]
 
 
static func _bend_tile(from_dir: Vector2i, to_dir: Vector2i) -> Vector2i:
	var key := Vector4i(from_dir.x, from_dir.y, to_dir.x, to_dir.y)
	var tile: Vector2i = BEND_TILES.get(key, NO_TILE)
	return tile if tile != NO_TILE else BODY_TILES[from_dir]
 
 
## Coloca los dos tiles extra de la esquina entre `cell` y `cell + dir` (diagonal).
static func _put_diagonal_spill(layer: TileMapLayer, cell: Vector2i, dir: Vector2i) -> void:
	var a := Vector2i(cell.x + dir.x, cell.y)
	var b := Vector2i(cell.x, cell.y + dir.y)
	var a_is_upper: bool
	var upper_tile: Vector2i
	var lower_tile: Vector2i
 
	if dir.x * dir.y < 0:
		# "/" : la celda "de arriba" es la de menor x+y
		a_is_upper = (a.x + a.y) < (b.x + b.y)
		upper_tile = SPILL_SLASH_UPPER
		lower_tile = SPILL_SLASH_LOWER
	else:
		# "\" : la celda "de arriba" es la de mayor x-y
		a_is_upper = (a.x - a.y) > (b.x - b.y)
		upper_tile = SPILL_BACK_UPPER
		lower_tile = SPILL_BACK_LOWER
 
	_put(layer, a, upper_tile if a_is_upper else lower_tile)
	_put(layer, b, lower_tile if a_is_upper else upper_tile)
 
 
static func _put(layer: TileMapLayer, cell: Vector2i, atlas_coords: Vector2i) -> void:
	if atlas_coords == NO_TILE:
		return
	layer.set_cell(cell, SOURCE_ID, atlas_coords)
 
