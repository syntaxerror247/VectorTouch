extends PanelContainer

const TopAppBar = preload("res://src/ui_parts/top_app_bar.tscn")
const CodeEditorScene = preload("res://src/ui_parts/code_editor.tscn")
const InspectorScene = preload("res://src/ui_parts/inspector.tscn")
const ViewportScene = preload("res://src/ui_parts/display.tscn")


var main_container: BoxContainer
var main_splitter: SplitContainer


func _ready() -> void:
	var shortcuts := ShortcutsRegistration.new()
	shortcuts.add_shortcut("view_show_grid", State.toggle_show_grid, ShortcutsRegistration.Behavior.PASS_THROUGH_AND_PRESERVE_POPUPS)
	shortcuts.add_shortcut("view_show_handles", State.toggle_show_handles, ShortcutsRegistration.Behavior.PASS_THROUGH_AND_PRESERVE_POPUPS)
	shortcuts.add_shortcut("view_rasterized_svg", State.toggle_view_rasterized, ShortcutsRegistration.Behavior.PASS_THROUGH_AND_PRESERVE_POPUPS)
	shortcuts.add_shortcut("view_show_reference", State.toggle_show_reference, ShortcutsRegistration.Behavior.PASS_THROUGH_AND_PRESERVE_POPUPS)
	shortcuts.add_shortcut("view_overlay_reference", State.toggle_overlay_reference, ShortcutsRegistration.Behavior.PASS_THROUGH_AND_PRESERVE_POPUPS)
	shortcuts.add_shortcut("load_reference", FileUtils.open_image_import_dialog, ShortcutsRegistration.Behavior.PASS_THROUGH_POPUPS)
	shortcuts.add_shortcut("toggle_snap", func() -> void: Configs.savedata.snap *= -1, ShortcutsRegistration.Behavior.PASS_THROUGH_AND_PRESERVE_POPUPS)
	shortcuts.add_shortcut("import", FileUtils.open_svg_import_dialog, ShortcutsRegistration.Behavior.PASS_THROUGH_POPUPS)
	shortcuts.add_shortcut("export", HandlerGUI.open_export, ShortcutsRegistration.Behavior.PASS_THROUGH_POPUPS)
	shortcuts.add_shortcut("save", FileUtils.save_svg, ShortcutsRegistration.Behavior.PASS_THROUGH_AND_PRESERVE_POPUPS)
	shortcuts.add_shortcut("save_as", FileUtils.save_svg_as, ShortcutsRegistration.Behavior.PASS_THROUGH_POPUPS)
	shortcuts.add_shortcut("close_tab", func() -> void: FileUtils.close_tabs(Configs.savedata.get_active_tab_index()),
			ShortcutsRegistration.Behavior.PASS_THROUGH_POPUPS)
	shortcuts.add_shortcut("close_all_other_tabs", func() -> void: FileUtils.close_tabs(Configs.savedata.get_active_tab_index(), FileUtils.TabCloseMode.ALL_OTHERS),
			ShortcutsRegistration.Behavior.PASS_THROUGH_POPUPS)
	shortcuts.add_shortcut("close_tabs_to_left", func() -> void: FileUtils.close_tabs(Configs.savedata.get_active_tab_index(), FileUtils.TabCloseMode.TO_LEFT),
			ShortcutsRegistration.Behavior.PASS_THROUGH_POPUPS)
	shortcuts.add_shortcut("close_tabs_to_right", func() -> void: FileUtils.close_tabs(Configs.savedata.get_active_tab_index(), FileUtils.TabCloseMode.TO_RIGHT),
			ShortcutsRegistration.Behavior.PASS_THROUGH_POPUPS)
	shortcuts.add_shortcut("close_empty_tabs", func() -> void: FileUtils.close_tabs(Configs.savedata.get_active_tab_index(), FileUtils.TabCloseMode.EMPTY),
			ShortcutsRegistration.Behavior.PASS_THROUGH_POPUPS)
	shortcuts.add_shortcut("close_saved_tabs", func() -> void: FileUtils.close_tabs(Configs.savedata.get_active_tab_index(), FileUtils.TabCloseMode.SAVED),
			ShortcutsRegistration.Behavior.PASS_THROUGH_POPUPS)
	shortcuts.add_shortcut("new_tab", Configs.savedata.add_empty_tab, ShortcutsRegistration.Behavior.PASS_THROUGH_POPUPS)
	shortcuts.add_shortcut("select_next_tab",
			func() -> void: Configs.savedata.set_active_tab_index(posmod(Configs.savedata.get_active_tab_index() + 1, Configs.savedata.get_tab_count())),
			ShortcutsRegistration.Behavior.PASS_THROUGH_POPUPS)
	shortcuts.add_shortcut("select_previous_tab",
			func() -> void: Configs.savedata.set_active_tab_index(posmod(Configs.savedata.get_active_tab_index() - 1, Configs.savedata.get_tab_count())),
			ShortcutsRegistration.Behavior.PASS_THROUGH_POPUPS)
	shortcuts.add_shortcut("optimize", State.optimize, ShortcutsRegistration.Behavior.STRICT_NO_PASSTHROUGH)
	shortcuts.add_shortcut("reset_svg", FileUtils.reset_svg, ShortcutsRegistration.Behavior.STRICT_NO_PASSTHROUGH)
	shortcuts.add_shortcut("debug", State.toggle_show_debug)
	shortcuts.add_shortcut("ui_undo", func() -> void: Configs.savedata.get_active_tab().undo(), ShortcutsRegistration.Behavior.STRICT_NO_PASSTHROUGH)
	shortcuts.add_shortcut("ui_redo", func() -> void: Configs.savedata.get_active_tab().redo(), ShortcutsRegistration.Behavior.STRICT_NO_PASSTHROUGH)
	shortcuts.add_shortcut("ui_cancel", State.clear_all_selections, ShortcutsRegistration.Behavior.STRICT_NO_PASSTHROUGH)
	shortcuts.add_shortcut("delete", State.delete_selected, ShortcutsRegistration.Behavior.STRICT_NO_PASSTHROUGH)
	shortcuts.add_shortcut("move_up", State.move_up_selected, ShortcutsRegistration.Behavior.STRICT_NO_PASSTHROUGH)
	shortcuts.add_shortcut("move_down", State.move_down_selected, ShortcutsRegistration.Behavior.STRICT_NO_PASSTHROUGH)
	shortcuts.add_shortcut("duplicate", State.duplicate_selected, ShortcutsRegistration.Behavior.STRICT_NO_PASSTHROUGH)
	shortcuts.add_shortcut("select_all", State.select_all, ShortcutsRegistration.Behavior.STRICT_NO_PASSTHROUGH)
	
	shortcuts.add_shortcut("move_absolute", State.respond_to_key_input.bind("M"))
	shortcuts.add_shortcut("move_relative", State.respond_to_key_input.bind("m"))
	shortcuts.add_shortcut("line_absolute", State.respond_to_key_input.bind("L"))
	shortcuts.add_shortcut("line_relative", State.respond_to_key_input.bind("l"))
	shortcuts.add_shortcut("horizontal_line_absolute", State.respond_to_key_input.bind("H"))
	shortcuts.add_shortcut("horizontal_line_relative", State.respond_to_key_input.bind("h"))
	shortcuts.add_shortcut("vertical_line_absolute", State.respond_to_key_input.bind("V"))
	shortcuts.add_shortcut("vertical_line_relative", State.respond_to_key_input.bind("v"))
	shortcuts.add_shortcut("close_path_absolute", State.respond_to_key_input.bind("Z"))
	shortcuts.add_shortcut("close_path_relative", State.respond_to_key_input.bind("z"))
	shortcuts.add_shortcut("elliptical_arc_absolute", State.respond_to_key_input.bind("A"))
	shortcuts.add_shortcut("elliptical_arc_relative", State.respond_to_key_input.bind("a"))
	shortcuts.add_shortcut("cubic_bezier_absolute", State.respond_to_key_input.bind("C"))
	shortcuts.add_shortcut("cubic_bezier_relative", State.respond_to_key_input.bind("c"))
	shortcuts.add_shortcut("shorthand_cubic_bezier_absolute", State.respond_to_key_input.bind("S"))
	shortcuts.add_shortcut("shorthand_cubic_bezier_relative", State.respond_to_key_input.bind("s"))
	shortcuts.add_shortcut("quadratic_bezier_absolute", State.respond_to_key_input.bind("Q"))
	shortcuts.add_shortcut("quadratic_bezier_relative", State.respond_to_key_input.bind("q"))
	shortcuts.add_shortcut("shorthand_quadratic_bezier_absolute", State.respond_to_key_input.bind("T"))
	shortcuts.add_shortcut("shorthand_quadratic_bezier_relative", State.respond_to_key_input.bind("t"))
	HandlerGUI.register_shortcuts(self, shortcuts)
	
	Configs.layout_changed.connect(update_layout)
	Configs.orientation_changed.connect(update_orientation)
	update_layout()

func update_orientation():
	if Configs.current_orientation == Configs.orientation.PORTRAIT:
		main_container.vertical = true
		main_splitter.vertical = true
	else:
		main_container.vertical = false
		main_splitter.vertical = false

func update_layout() -> void:
	for child in get_children():
		child.queue_free()
	
	var side_panel_top := Configs.savedata.get_layout_parts(SaveData.LayoutLocation.SIDE_PANEL_TOP)
	var side_panel_bottom := Configs.savedata.get_layout_parts(SaveData.LayoutLocation.SIDE_PANEL_BOTTOM)
	
	var root_container = VBoxContainer.new()
	add_child(root_container)
	
	# Setup the top bar.
	root_container.add_child(TopAppBar.instantiate())
	
	# Create main container, it would contain side panel, viewport, and shortcut panel.
	main_container = BoxContainer.new()
	main_container.vertical = true
	main_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	main_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root_container.add_child(main_container)
	
	# Set up the main splitter.
	main_splitter = SplitContainer.new()
	main_splitter.vertical = true
	main_splitter.dragger_visibility = SplitContainer.DRAGGER_HIDDEN_COLLAPSED
	main_splitter.touch_dragger_enabled = true
	main_splitter.split_offset = Configs.savedata.main_splitter_offset
	main_splitter.dragged.connect(_on_main_splitter_dragged)
	main_splitter.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	main_splitter.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main_container.add_child(main_splitter)
	
	var side_panel_margin_container := MarginContainer.new()
	side_panel_margin_container.begin_bulk_theme_override()
	side_panel_margin_container.add_theme_constant_override("margin_top", 6)
	side_panel_margin_container.add_theme_constant_override("margin_bottom", 3)
	side_panel_margin_container.add_theme_constant_override("margin_left", 6)
	side_panel_margin_container.add_theme_constant_override("margin_right", 6)
	side_panel_margin_container.end_bulk_theme_override()
	main_splitter.add_child(side_panel_margin_container)
	
	var main_view_margin_container := MarginContainer.new()
	main_view_margin_container.add_theme_constant_override("margin_top", 3)
	main_view_margin_container.add_child(create_layout_node(Utils.LayoutPart.VIEWPORT))
	main_splitter.add_child(main_view_margin_container)
	
	var side_panel_vbox := VBoxContainer.new()
	side_panel_vbox.add_theme_constant_override("separation", 6)
	side_panel_margin_container.add_child(side_panel_vbox)
	
	if not side_panel_top.is_empty() and not side_panel_bottom.is_empty():
		# Layout parts both on top and on the bottom.
		var side_panel_split_container := VSplitContainer.new()
		side_panel_split_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
		side_panel_split_container.dragger_visibility = SplitContainer.DRAGGER_HIDDEN_COLLAPSED
		side_panel_split_container.touch_dragger_enabled = true
		side_panel_split_container.split_offset = Configs.savedata.side_panel_splitter_offset
		side_panel_split_container.dragged.connect(_on_side_panel_splitter_dragged)
		side_panel_split_container.add_child(create_layout_node(side_panel_top[0]))
		side_panel_split_container.add_child(create_layout_node(side_panel_bottom[0]))
		side_panel_vbox.add_child(side_panel_split_container)
	elif side_panel_top.size() == 2 or side_panel_bottom.size() == 2:
		# Tabs for the different layout parts.
		var layout_parts := side_panel_top if side_panel_bottom.is_empty() else side_panel_bottom
		var vbox := VBoxContainer.new()
		vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
		var buttons_hbox := HBoxContainer.new()
		buttons_hbox.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		buttons_hbox.add_theme_constant_override("separation", 10)
		vbox.add_child(buttons_hbox)
		
		var layout_nodes: Dictionary[Utils.LayoutPart, Node] = {}
		for part in layout_parts:
			var layout_node := create_layout_node(part)
			layout_nodes[part] = layout_node
			layout_node.hide()
			vbox.add_child(layout_node)
		
		var btn_group := ButtonGroup.new()
		for i in layout_parts.size():
			var part := layout_parts[i]
			var btn := Button.new()
			# Make the text update when the language changes.
			var set_btn_text_func := func() -> void:
					btn.text = TranslationUtils.get_layout_part_name(part)
			Configs.language_changed.connect(set_btn_text_func)
			set_btn_text_func.call()
			# Set up other button properties.
			btn.toggle_mode = true
			btn.icon = Utils.get_layout_part_icon(part)
			btn.theme_type_variation = "FlatButton"
			btn.focus_mode = Control.FOCUS_NONE
			btn.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
			btn.button_group = btn_group
			for node_part in layout_nodes:
				btn.toggled.connect(func(_toggled_on: bool) -> void:
						layout_nodes[node_part].visible = (node_part == part))
			if part == Utils.LayoutPart.INSPECTOR:
				State.requested_scroll_to_selection.connect(btn.set_pressed.bind(true).unbind(2))
			buttons_hbox.add_child(btn)
			if i == 0:
				btn.button_pressed = true
				layout_nodes[part].show()
		side_panel_vbox.add_child(vbox)
	else:
		# Layout parts disabled.
		if not side_panel_top.is_empty():
			side_panel_vbox.add_child(create_layout_node(side_panel_top[0]))
		elif not side_panel_bottom.is_empty():
			side_panel_vbox.add_child(create_layout_node(side_panel_bottom[0]))
	
	HandlerGUI.minimum_content_width = get_minimum_size().x

func _on_main_splitter_dragged(offset: int) -> void:
	Configs.savedata.main_splitter_offset = offset

func _on_side_panel_splitter_dragged(offset: int) -> void:
	Configs.savedata.side_panel_splitter_offset = offset


func create_layout_node(layout_part: Utils.LayoutPart) -> Node:
	match layout_part:
		Utils.LayoutPart.CODE_EDITOR: return CodeEditorScene.instantiate()
		Utils.LayoutPart.INSPECTOR: return InspectorScene.instantiate()
		Utils.LayoutPart.VIEWPORT: return ViewportScene.instantiate()
		_: return Control.new()
