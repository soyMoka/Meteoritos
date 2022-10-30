class_name ReleDeMasa
extends Node2D


## Metods Custom
func atraer_player(body:Node) -> void:
	$Tween.interpolate_property(
		body,
		'global_position',
		body.global_position,
		global_position,
		1.0,
		Tween.TRANS_SINE,
		Tween.EASE_IN
	)
	$Tween.start()

##Seniales Internas

func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	if anim_name == "spawn":
		$AnimationPlayer.play("activado")


func _on_DetectorPlayer_body_entered(body: Node) -> void:
	if body.name == 'Player':
		$DetectorPlayer/CollisionShape2D.set_deferred('disabled', true)
		$AnimationPlayer.play("super_activado")
		body.desactivar_controles()
		body.get_scene_instance_load_placeholder()
		
		atraer_player(body)


func _on_Tween_tween_all_completed() -> void:
	print('*Siguiente nivel*')
