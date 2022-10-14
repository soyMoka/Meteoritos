class_name ProyectilPlayer
extends Area2D

## Atributo
var velocidad:Vector2 = Vector2.ZERO
var danio:float 


## Metodos
func crear(pos: Vector2, dir: float, vel: float, danio_p: int) -> void:
	position = pos
	rotation = dir
	velocidad = Vector2(vel, 0).rotated(dir)
	danio = danio_p

func _physics_process(delta: float) -> void:
	position += velocidad * delta


##Metodos custom
func daniar(otro_cuerpo: CollisionObject2D) -> void:
	print(otro_cuerpo.name)
	if otro_cuerpo.has_method('recibir_danio'):
		otro_cuerpo.recibir_danio(danio)
	queue_free()

## señales internas
func _on_VisibilityNotifier2D_screen_exited()->void:
	queue_free()


func _on_Proyectil_area_entered(area: Area2D)->void:
	daniar(area)
	


func _on_Proyectil_body_entered(body: Node) -> void:
	daniar(body)
