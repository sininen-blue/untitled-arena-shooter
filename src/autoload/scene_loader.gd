extends Node

signal progress_changed(progress: float)
signal load_finished


var loading_screen: PackedScene = preload("uid://k7eur5nkm4l0")
var loaded_resource: PackedScene
var scene_path: String
var progress: Array = []

var use_sub_threads: bool = true


func _ready() -> void:
	set_process(false)


func _process(_delta: float) -> void:
	var load_status: int = ResourceLoader.load_threaded_get_status(scene_path, progress)
	progress_changed.emit(progress[0])
	
	match load_status:
		ResourceLoader.THREAD_LOAD_INVALID_RESOURCE, ResourceLoader.THREAD_LOAD_FAILED:
			set_process(false)
		ResourceLoader.THREAD_LOAD_LOADED:
			loaded_resource = ResourceLoader.load_threaded_get(scene_path)
			
			get_tree().change_scene_to_packed(loaded_resource)
			load_finished.emit()


func load_scene(to: String) -> void:
	scene_path = to
	
	var new_load_screen = loading_screen.instantiate()
	add_child(new_load_screen)
	
	progress_changed.connect(new_load_screen._on_scene_loader_progress_changed)
	load_finished.connect(new_load_screen._on_scene_loader_load_finished)
	
	await new_load_screen.loading_screen_ready
	
	self.start_load()


func start_load() -> void:
	var state: Error = ResourceLoader.load_threaded_request(scene_path, "", use_sub_threads) 
	
	if state == OK:
		set_process(true)
