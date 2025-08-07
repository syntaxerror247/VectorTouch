extends PanelContainer

const tabItem = preload("res://src/ui_widgets/tab_item.tscn")

@onready var tab_container: VBoxContainer = $VBoxContainer/ScrollContainer/VBoxContainer

var should_refresh = false

func _ready() -> void:
	get_parent().gui_input.connect(_on_parent_gui_input)
	Configs.tab_removed.connect(refresh_tabs)
	Configs.tab_selected.connect(highlight_active_tab)
	Configs.theme_changed.connect(sync_theming)
	sync_theming()
	Configs.tabs_changed.connect(func(): should_refresh = true)
	refresh_tabs()

func sync_theming():
	var scroll_bar: VScrollBar=  $VBoxContainer/ScrollContainer.get_v_scroll_bar()
	scroll_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var s: StyleBoxFlat = scroll_bar.get_theme_stylebox("scroll").duplicate()
	s.draw_center = false
	s.content_margin_left = 2
	s.content_margin_right = 2
	scroll_bar.add_theme_stylebox_override("scroll", s)

func animate_in() -> void:
	if should_refresh:
		refresh_tabs()
	var tween := get_tree().create_tween()
	tween.tween_property(self, "position:x", 0, 0.3).from(-200).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

func animate_out() -> void:
	var tween := get_tree().create_tween()
	tween.tween_property(self, "position:x", -200, 0.3).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	await tween.finished
	get_parent().hide()
	should_refresh = false

func refresh_tabs() -> void:
	should_refresh = false
	for i in tab_container.get_children():
		i.queue_free()
	
	var has_transient_tab := not State.transient_tab_path.is_empty()
	var total_tabs := Configs.savedata.get_tab_count()
	
	# If there's a transient tab, we want to draw one more
	if has_transient_tab:
		total_tabs += 1
	
	for tab_index in total_tabs:
		var is_transient := (has_transient_tab and tab_index == total_tabs)
		var tab_name := ""
		var svg_text := ""
		
		if is_transient:
			tab_name = State.transient_tab_path.get_file()
		else:
			var tab_data = Configs.savedata.get_tab(tab_index)
			if tab_data._sync_pending:
				await tab_data.data_synced
			tab_name = tab_data.presented_name
			svg_text = FileAccess.get_file_as_string(TabData.get_edited_file_path_for_id(tab_data.id))
			if tab_data.marked_unsaved:
				tab_name = "* " + tab_name
		
		var is_active := (
			(is_transient and has_transient_tab) or
			(not is_transient and tab_index == Configs.savedata.get_active_tab_index())
		)
		
		var tab = tabItem.instantiate()
		tab_container.add_child(tab)
		tab.setup(tab_name, svg_text, is_active)

func highlight_active_tab(new_index: int) -> void:
	var active_index = Configs.savedata.get_active_tab_index()
	tab_container.get_child(active_index).highlight(false)
	Configs.savedata.set_active_tab_index(new_index)
	tab_container.get_child(new_index).highlight(true)

func _on_new_tab_pressed() -> void:
	Configs.savedata.add_empty_tab()
	refresh_tabs()

func _on_parent_gui_input(event: InputEvent) -> void:
	if not event is InputEventMouseButton:
		return
	if event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		animate_out()
