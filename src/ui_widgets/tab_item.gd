extends PanelContainer

const PreviewRectScene = preload("res://src/ui_widgets/preview_rect.tscn")

@onready var title: Label = $VBoxContainer/HBoxContainer/title
@onready var close_button: Button = $VBoxContainer/HBoxContainer/close

var _click_start_time := 0
var _dragged := false
const CLICK_MAX_TIME := 300


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
	if event is InputEventMouseMotion:
		_dragged = true
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.is_pressed():
				_click_start_time = Time.get_ticks_msec()
				_dragged = false
			else:
				var time_diff := Time.get_ticks_msec() - _click_start_time
				if time_diff <= CLICK_MAX_TIME and not _dragged:
					Configs.tab_selected.emit(get_index())
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			if event.is_pressed():
				Configs.tab_multi_selection_enabled.emit(true)
				Configs.tab_selected.emit(get_index())

func _on_close_pressed() -> void:
	FileUtils.close_tabs(get_index())
	
