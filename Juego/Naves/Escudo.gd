#Escudo.gd
extends Area2D
class_name Escudo


## Variavles
var esta_activado:bool = false setget ,get_esta_activado
var energia_original = energia
## Variables Export
export var energia:float= 10.0
export var radio_desgaste = -1.6


##setters y Getters
func get_esta_activado()->bool:
	return esta_activado
	

## Metodos
func _ready() -> void:
	energia_original = energia
	set_process(false)
	controlar_colisionador(true)


func _process(delta: float) -> void:
	controlar_energia(radio_desgaste * delta)	
	
	
## Metodos Custom
func controlar_energia(consumo:float)->void:
	energia += consumo
	
	if energia > energia_original:
		energia = energia_original
	elif energia <= 0.0:
		Eventos.emit_signal("ocultar_energia_escudo")
		desactivar()
		return
	Eventos.emit_signal("cambio_energia_escudo", energia_original, energia)

func controlar_colisionador(esta_desactivado:bool)->void:
	$CollisionShape2D.set_deferred('disabled', esta_desactivado)


func activar() -> void:
	if energia <= 0.0:
		return
	esta_activado=true
	controlar_colisionador(false)
	$AnimationPlayer.play("activando")


func desactivar() -> void:
	set_process(false)
	esta_activado = false
	controlar_colisionador(true)
	$AnimationPlayer.play_backwards("activando")
	Eventos.emit_signal("ocultar_energia_escudo")
		
## Señales internas
func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	if anim_name == 'activando' and esta_activado:
		$AnimationPlayer.play("activado")
		set_process(true) # activa el metodo  _proces


func _on_Escudo_area_entered(area: Area2D) -> void:
	pass # Replace with function body.


func _on_Escudo_body_entered(body: Node) -> void:
	body.queue_free()
