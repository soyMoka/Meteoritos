class_name BaseEnemiga
extends Node2D

## Atributos Export
export var hitpoints:float = 30.0
export var orbital:PackedScene = null
export var numero_orbitales:int = 10
export var intervalo_spawner:float = 0.8

## Atributos Onready
onready var impacto_sfx:AudioStreamPlayer2D = $ImpactosSFX
onready var timer_spawner:Timer = $TimerSpawnerEnemigos

## Atributos
var esta_destruida:bool = false
var posicion_spawn:Vector2 = Vector2.ZERO

## Metodos
func _ready() -> void:
	timer_spawner.wait_time = intervalo_spawner
	$AnimationPlayer.play(elegir_animacion_aleatoria())
	
#func _process(delta:float) -> void:
#	var player_objetivo:Player = DatosJuego.get_player_actual()
#	if not player_objetivo:
#		return
#
#	var dir_player:Vector2 = player_objetivo.global_position - global_position
#	var angulo_player:float = rad2deg(dir_player.angle())
#	print(angulo_player)
	
## Metodos Custom	
func elegir_animacion_aleatoria() -> String:
	randomize()
	var num_anim:int = $AnimationPlayer.get_animation_list().size() - 1
	var indice_anim_aleatoria:int = randi()% num_anim + 1
	var lista_animacion:Array = $AnimationPlayer.get_animation_list()
	
	return lista_animacion[indice_anim_aleatoria]


func recibir_danio(danio:float)->void:
	hitpoints -= danio
	
	if hitpoints <= 0 and not esta_destruida:
		esta_destruida = true
		destruir()
	
	impacto_sfx.play()


func spawner_orbital():
	numero_orbitales -= 1
	$RutaEnemigo.global_position = global_position
	
#	var pos_spawn:Vector2= deteccion_cuadrante()
	
	var new_orbital:EnemigoOrbital = orbital.instance()
	new_orbital.create(
		global_position + posicion_spawn,
		self, 
		$RutaEnemigo
	)
	
	Eventos.emit_signal("spawn_orbital", new_orbital)

func deteccion_cuadrante()->Vector2:
	var player_objetivo:Player = DatosJuego.get_player_actual()
	
	if not player_objetivo:
		return Vector2.ZERO
		
	var dir_player:Vector2 = player_objetivo.global_position - global_position
	var angulo_player:float = rad2deg(dir_player.angle())
	
	if abs(angulo_player) <= 45.0:
		# Player entra por la derecha
		$RutaEnemigo.rotation_degrees = 180
		return $PosicionesSpawn/Este.position
	elif abs(angulo_player) > 135.0 and abs(angulo_player) <= 180.0 :
		# Player entra por la Izquierda
		$RutaEnemigo.rotation_degrees = 0.0
		return $PosicionesSpawn/Oeste.position
	elif abs(angulo_player) > 45.0 and abs(angulo_player) <= 135.0  :
		# Player entra por arriba o  abajo
		if sign(angulo_player) > 0:
			# Player entra por abajo
			$RutaEnemigo.rotation_degrees = 270.0
			return $PosicionesSpawn/Sur.position
		else:
			# Player entra por arriba o  abajo
			$RutaEnemigo.rotation_degrees = 90.0			
			return $PosicionesSpawn/Norte.position
	
	return $PosicionesSpawn/Norte.position
			
		
func destruir()->void:
	var posicion_partes = [
		$Sprites/Body.global_position,
		$Sprites/Brazo.global_position,
		$Sprites/Cabeza.global_position,
		$Sprites/Cuello.global_position
	]
	Eventos.emit_signal('base_destruida', self,  posicion_partes)
	queue_free()

	

## Seniales Internas
func _on_AreaColision_body_entered(body: Node) -> void:
	if body.has_method('destruir'):
		body.destruir()
		
func _on_VisibilityNotifier2D_screen_entered() -> void:
	#spawn Orbitales
	$VisibilityNotifier2D.queue_free()
	posicion_spawn = deteccion_cuadrante()
	spawner_orbital()
	timer_spawner.start()
#	var new_orbital:EnemigoOrbital = orbital.instance()
#	new_orbital.create(
#		global_position + $PosicionesSpawn/Norte.global_position, self
#	)
#	Eventos.emit_signal("spawn_orbital", new_orbital)


func _on_TimerSpawnerEnemigos_timeout() -> void:
	if numero_orbitales == 0:
		timer_spawner.stop()
		return
	spawner_orbital()
