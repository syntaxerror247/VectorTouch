extends PanelContainer

const PreviewRectScene = preload("res://src/ui_widgets/preview_rect.tscn")

@onready var title: Label = $VBoxContainer/HBoxContainer/title
@onready var close_button: Button = $VBoxContainer/HBoxContainer/close

func setup(tab_title: String, svg_text: String, is_active: bool = false) -> void:
	title.text = tab_title
	highlight(is_active)
	var preview_rect := PreviewRectScene.instantiate()
	$VBoxContainer/HBoxContainer.add_sibling(preview_rect)
	preview_rect.custom_minimum_size = Vector2(96, 96)
	preview_rect.size = Vector2.ZERO
	if not svg_text.is_empty():
		preview_rect.setup_svg_without_dimensions(svg_text)
	preview_rect.shrink_to_fit(16, 16)

func highlight_active_tab() -> void:
	var active_index := Configs.savedata.get_active_tab_index()
	print("active_index ", active_index)
	if get_index() == active_index:
		highlight(true)
	else:
		highlight(false)

func highlight(is_active: bool) -> void:
	if is_active:
		theme_type_variation = "TabItemActive"
	else:
		theme_type_variation = "TabItem"

func _gui_input(event: InputEvent) -> void:
	if not event is InputEventMouseButton:
		return
	if event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		var index := get_index()
		Configs.tab_selected.emit(index)
	

func _on_close_pressed() -> void:
	FileUtils.close_tabs(get_index())
	
