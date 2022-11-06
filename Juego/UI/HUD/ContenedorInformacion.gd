class_name ContenedorInformacion
extends NinePatchRect

## Atributos
var esta_activo:bool = true setget set_esta_activo


## Atributos Export
export var auto_ocultar:bool = false


## Atributos Onready
onready var texto_contenedor:Label = $Label
onready var auto_ocultar_timer:Timer = $AutoOcultarTimer
onready var animaciones:AnimationPlayer = $AnimationPlayer

## setter y getters
func set_auto_ocultar(estado:bool):
	if estado:
		auto_ocultar_timer.start()
	
func set_esta_activo(valor:bool)->void:
	esta_activo = valor
		
## Metodos
func mostrar()->void:
	if esta_activo:
		$AnimationPlayer.play("Mostrar")


func ocultar()->void:
	if not esta_activo:
		animaciones.stop()
	$AnimationPlayer.play("Ocultar")

	
func mostrar_suavizado()->void:
	if not esta_activo:
		return
	$AnimationPlayer.play("Mostrar_suavizado")
	if auto_ocultar:
		auto_ocultar_timer.start()


func ocultar_suavizado()->void:
	if esta_activo:
		$AnimationPlayer.play("Ocultar_suavemente")
	

func modificar_texto(texto:String)->void:
	texto_contenedor.text = texto


func _on_AutoOcultarTimer_timeout() -> void:
	ocultar_suavizado()
