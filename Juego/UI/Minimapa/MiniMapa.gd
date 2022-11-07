extends MarginContainer

## Atributos Export
export var escala_zoom:float = 4.0
export var tiempo_visible:float = 15.0


## Atributos 
var escala_grilla:Vector2
var player:Player=null
var esta_visible:bool = true setget set_esta_visible

var esta_activo:bool = true setget set_esta_activo



## Atributos Onready
onready var zona_renderizado:TextureRect=$CuadroMinimapa/ContenedorMinis/ZonaRenderizadoMinis
onready var icono_player:Sprite = $CuadroMinimapa/ContenedorMinis/ZonaRenderizadoMinis/IconoPlayer
onready var icono_base_enemiga:Sprite = $CuadroMinimapa/ContenedorMinis/ZonaRenderizadoMinis/IconoBaseEnemiga
onready var icono_estacion_recarga:Sprite = $CuadroMinimapa/ContenedorMinis/ZonaRenderizadoMinis/IconoEstacion
onready var items_mini_mapa:Dictionary = {}
onready var icono_interceptor:Sprite = $CuadroMinimapa/ContenedorMinis/ZonaRenderizadoMinis/IconoInterceptor
onready var icono_rele:Sprite = $CuadroMinimapa/ContenedorMinis/ZonaRenderizadoMinis/IconoRele
onready var timer_visibilidad:Timer = $TimerVisibilidad
onready var tween_visibilidad:Tween = $TweenVisibilidad

## Setters y Getters

func set_esta_activo(valor:bool)->void:
	esta_activo = valor
		

func set_esta_visible(hacer_visible:bool)->void:
	if hacer_visible:
		timer_visibilidad.start()
	
	esta_visible = hacer_visible
	
	var transparencia = 0.5
	
	if esta_visible == false:
		tween_visibilidad.interpolate_property(
			self,
			'modulate',
			Color(1,1,1, 0),
			Color(1,1,1, transparencia ),
			0.5,
			Tween.TRANS_LINEAR,
			Tween.EASE_IN_OUT
			)
	else:
		tween_visibilidad.interpolate_property(
		self,
		'modulate',
		Color(1,1,1, transparencia),
		Color(1,1,1, 0 ),
		0.5,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN_OUT
		)
	tween_visibilidad.start()

## Metodos
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("minimapa"):
		set_esta_visible(not esta_visible)


func _ready() -> void:
	set_process(false)
	icono_player.position = zona_renderizado.rect_size * 0.5
	escala_grilla = zona_renderizado.rect_size/(get_viewport_rect().size * escala_zoom)
	conectar_seniales()
	

func _process(delta: float) -> void:
	if not player:
		return
	icono_player.rotation_degrees = player.rotation_degrees + 90
	modificar_posicion_iconos()


## Metodos Custom
func conectar_seniales()->void:
	Eventos.connect("nivel_iniciado",self, '_on_nivel_iniciado')
	Eventos.connect("nave_destruida",self , '_on_nave_destruida')
	Eventos.connect("minimapa_objeto_creado",self , 'obtener_objetos_minimapa')
	Eventos.connect("minimapa_objeto_destruido",self , 'quitar_icono')
	
func quitar_icono(objeto:Node2D)->void:
	if objeto in items_mini_mapa:
		items_mini_mapa[objeto].queue_free()
		items_mini_mapa.erase(objeto)

func _on_nivel_iniciado()->void:
	player = DatosJuego.get_player_actual()
	obtener_objetos_minimapa()
	set_process(true)
	
	

func _on_nave_destruida(nave: NaveBase, _position, _explosiones)->void:
	if nave is Player:
		player = null

func obtener_objetos_minimapa()->void:
	var objetos_en_ventana:Array = get_tree().get_nodes_in_group('minimap')
	for objeto in objetos_en_ventana:
		if not items_mini_mapa.has(objeto):
			var sprite_icono:Sprite
			if objeto is BaseEnemiga:
				sprite_icono = icono_base_enemiga.duplicate()
			elif objeto is EstacionRecarga:
				sprite_icono = icono_estacion_recarga.duplicate()
			elif objeto is EnemigoIntercept:
				sprite_icono = icono_interceptor.duplicate()
			elif objeto is ReleDeMasa:
				sprite_icono = icono_rele.duplicate()
			

			items_mini_mapa[objeto] = sprite_icono
			items_mini_mapa[objeto].visible = true
			zona_renderizado.add_child(items_mini_mapa[objeto])
		
func modificar_posicion_iconos() -> void:
	for item in items_mini_mapa:
		var item_icono:Sprite=items_mini_mapa[item]
		var offset_pos:Vector2 = item.position - player.position
		#var pos_icono:Vector2= offset_pos * escala_grilla + (zona_renderizado.rect_size * 0.5)
		var pos_icono:Vector2= offset_pos * escala_grilla + icono_player.position
		pos_icono.x = clamp(pos_icono.x, 0, zona_renderizado.rect_size.x)
		pos_icono.y = clamp(pos_icono.y, 0, zona_renderizado.rect_size.y)
		item_icono.position = pos_icono
		
		if zona_renderizado.get_rect().has_point(pos_icono - zona_renderizado.rect_position):
			item_icono.scale = Vector2(0.5, 0.5)
		else:
			item_icono.scale = Vector2(0.3, 0.3)


func _on_TimerVisibilidad_timeout() -> void:
	if esta_visible:
		set_esta_visible(false)
