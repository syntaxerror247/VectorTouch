# MIT License
#
# Copyright (c) 2024-present Anish Mishra (syntaxerror247)
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

@tool
extends Node

const _plugin_name: String = "SystemBarColorChanger"
var is_light_status_bar: bool = false
var is_light_navigation_bar: bool = false

var android_runtime: Object

func _ready() -> void:
	if Engine.has_singleton("AndroidRuntime"):
		android_runtime = Engine.get_singleton("AndroidRuntime")
		var layout_params = JavaClassWrapper.wrap("android.view.WindowManager$LayoutParams")
		var window = android_runtime.getActivity().getWindow()
		window.addFlags(layout_params.FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS)
	else:
		printerr("AndroidRuntime singleton not found! Try it on an Android device.")


func set_status_bar_color(color: Color) -> void:
	if not android_runtime:
		printerr("%s plugin not initialized!" % _plugin_name)
		return
	
	var activity = android_runtime.getActivity()
	var callable = func ():
		var window = activity.getWindow()
		window.setStatusBarColor(color.to_argb32())
		if is_light_status_bar != (color.get_luminance() > 0.6):
			is_light_status_bar = color.get_luminance() > 0.6
			var wic = JavaClassWrapper.wrap("android.view.WindowInsetsController")
			var insets_controller = window.getInsetsController()
			insets_controller.setSystemBarsAppearance(
				wic.APPEARANCE_LIGHT_STATUS_BARS if is_light_status_bar else 0,
				wic.APPEARANCE_LIGHT_STATUS_BARS)
	
	activity.runOnUiThread(android_runtime.createRunnableFromGodotCallable(callable))


func set_navigation_bar_color(color: Color) -> void:
	if not android_runtime:
		printerr("%s plugin not initialized!" % _plugin_name)
		return
	
	var activity = android_runtime.getActivity()
	var callable = func ():
		var window = activity.getWindow()
		window.setNavigationBarColor(color.to_argb32())
		if is_light_navigation_bar != (color.get_luminance() > 0.6):
			is_light_navigation_bar = color.get_luminance() > 0.6
			var wic = JavaClassWrapper.wrap("android.view.WindowInsetsController")
			var insets_controller = window.getInsetsController()
			insets_controller.setSystemBarsAppearance(
				wic.APPEARANCE_LIGHT_NAVIGATION_BARS if is_light_navigation_bar else 0,
				wic.APPEARANCE_LIGHT_NAVIGATION_BARS)
	
	activity.runOnUiThread(android_runtime.createRunnableFromGodotCallable(callable))


func set_translucent_system_bars(translucent = true) -> void:
	if not android_runtime:
		printerr("%s plugin not initialized!" % _plugin_name)
		return
	
	var activity = android_runtime.getActivity()
	var callable = func ():
		var layout_params = JavaClassWrapper.wrap("android.view.WindowManager$LayoutParams")
		var window = activity.getWindow()
		if translucent:
			window.addFlags(layout_params.FLAG_TRANSLUCENT_STATUS)
			window.addFlags(layout_params.FLAG_TRANSLUCENT_NAVIGATION)
		else:
			window.clearFlags(layout_params.FLAG_TRANSLUCENT_STATUS)
			window.clearFlags(layout_params.FLAG_TRANSLUCENT_NAVIGATION)
	
	activity.runOnUiThread(android_runtime.createRunnableFromGodotCallable(callable))
