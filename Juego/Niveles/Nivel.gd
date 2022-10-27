class_name Nivel
extends Node2D

## Atributos Onready
onready var contenedor_proyectiles:Node
onready var contenedor_meteoritos:Node 
onready var contenedor_sector_meteoritos:Node
onready var camara_nivel:Camera2D = $CameraNivel

## Atributos Export
export var explosion:PackedScene = null
export var meteorito:PackedScene = null
export var explosion_meteorito:PackedScene = null
export var sector_meteoritos:PackedScene = null
export var tiempo_transicion_camara:float = 2.0


## Atributos
var meteoritos_totales:int = 0


## Metodos
func _ready() -> void:
	conectar_seniales()
	crear_contenedores()
	
	
## Conexion señales externas


func conectar_seniales() -> void:
	Eventos.connect("disparo", self, '_on_disparo')
	Eventos.connect("nave_destruida", self, '_on_nave_destruida')
	Eventos.connect("spawn_meteorito", self, "_on_spawn_meteoritos")
	Eventos.connect("meteorito_destruido", self, "_on_meteorito_destruido")
	Eventos.connect("nave_en_sector_peligro", self, '_on_nave_en_sector_peligro')
	
## Metodos Custom	

func crear_posicion_aleatoria(rango_horizontal: float, rango_vertical: float) ->Vector2:
	randomize()
	var rand_x = rand_range(-rango_horizontal, rango_horizontal)
	var rand_y = rand_range(-rango_vertical, rango_vertical)
	return Vector2(rand_x, rand_y)	
	

func crear_contenedores() -> void:
	contenedor_proyectiles = Node.new()
	contenedor_proyectiles.name = 'ContenedorProyectiles'
	contenedor_meteoritos = Node.new()
	contenedor_meteoritos.name = 'ContenedorMeteoritos'
	contenedor_sector_meteoritos = Node.new()
	contenedor_sector_meteoritos.name = 'ContenedorSectorMeteoritos'
	
	add_child(contenedor_sector_meteoritos)
	add_child(contenedor_meteoritos)
	add_child(contenedor_proyectiles)


func _on_disparo(proyectl:ProyectilPlayer) ->void:
	contenedor_proyectiles.add_child(proyectl)


func crear_sector_meteoritos(centro_camara:Vector2, numero_peligros:int) ->void:
	meteoritos_totales = numero_peligros
	var new_sector_meteoritos:SectorMeteoritos = sector_meteoritos.instance()
	new_sector_meteoritos.crear(centro_camara, numero_peligros) 
	camara_nivel.global_position = centro_camara
	contenedor_sector_meteoritos.add_child(new_sector_meteoritos)
	camara_nivel.zoom = $Player/Camera2D.zoom
	camara_nivel.devolver_zoom_original()
	transicion_camaras(
		$Player/Camera2D.global_position,
		camara_nivel.global_position,
		camara_nivel,
		tiempo_transicion_camara
		)


func transicion_camaras(
	desde:Vector2, 
	hasta:Vector2, 
	camara_actual:Camera2D,
	tiempo_transicion:float
	)->void:
	$CameraNivel/TweenCamara.interpolate_property(
		camara_actual,
		'global_position',
		desde,
		hasta,
		tiempo_transicion,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN_OUT
	)
	camara_actual.current = true
	$CameraNivel/TweenCamara.start()


func controlar_meteoritos_restantes() ->void:
	meteoritos_totales -= 1 
	#aca podemos imprimir los meteoritos restantes para mirar
	if meteoritos_totales == 0:
		contenedor_sector_meteoritos.get_child(0).queue_free()
		$Player/Camera2D.set_puede_hacer_zoom(true)
		var zoom_actual = $Player/Camera2D.zoom
		$Player/Camera2D.zoom = camara_nivel.zoom
		$Player/Camera2D.zoom_suavizado(zoom_actual.x, zoom_actual.y, 1.0)
		transicion_camaras(
			camara_nivel.global_position,
			$Player/Camera2D.global_position,
			$Player/Camera2D,
			tiempo_transicion_camara*0.10
		)


## Señales internas
func _on_TweenCamara_tween_completed(object: Object, key: NodePath) -> void:
	if object.name == 'Camera2D':
		object.global_position = $Player.global_position
		

## Conexion señales externas
func _on_nave_destruida(nave:Player, position:Vector2, num_explosiones:int) ->void :
	if nave is Player:
		transicion_camaras(
			position,
			position + crear_posicion_aleatoria(-200.0, 200.0),
			camara_nivel,
			tiempo_transicion_camara
		)
	for i in range(num_explosiones):
		var new_explosion:Node2D = explosion.instance()
		new_explosion.global_position = position + crear_posicion_aleatoria(100.0, 50.0)
		add_child(new_explosion)
		yield(get_tree().create_timer(0.6),"timeout")

func _on_spawn_meteoritos(pos_spawn: Vector2, dir_meteorito: Vector2, tamanio:float) -> void:
	var new_meteorito:Meteorito = meteorito.instance()
	new_meteorito.crear(
		pos_spawn,
		dir_meteorito,
		tamanio
	)
	contenedor_meteoritos.add_child(new_meteorito)
	
func _on_meteorito_destruido(pos:Vector2)->void:
	var new_explosion:ExplosionMeteorito = explosion_meteorito.instance()
	new_explosion.global_position = pos
	add_child(new_explosion)
	
	controlar_meteoritos_restantes()

func _on_nave_en_sector_peligro(centro_cam:Vector2, tipo_peligro:String, num_peligros:int)->void:
	if tipo_peligro == 'Meteorite':
		#Vamos a crear dinamicamente al sectorMeteoritos
		crear_sector_meteoritos(centro_cam, num_peligros)
	elif tipo_peligro == 'Enemigo':
		pass

