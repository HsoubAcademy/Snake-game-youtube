extends CanvasLayer


var time = 0

func _process(delta: float) -> void:
	$TimerLabel.text = str("TIMER : ",time)

func _on_timer_timeout() -> void:
	time += 1
