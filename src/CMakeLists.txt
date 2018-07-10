# files we want to compile
include(ValaPrecompile)
vala_precompile(VALA_C ${EXEC_NAME}
	Main.vala
	Application.vala
	Window.vala

	Models/Header.vala
	Models/RequestItem.vala
	Models/ResponseItem.vala

	Controllers/RequestController.vala

	Services/Settings.vala

	Widgets/AbstractTypeView.vala
	Widgets/Content.vala
	Widgets/HeaderBar.vala
	Widgets/HeaderField.vala
	Widgets/HeaderView.vala
	Widgets/HtmlView.vala
	Widgets/JsonView.vala
	Widgets/Preferences.vala
	Widgets/RequestDialog.vala
	Widgets/RequestHistory.vala
	Widgets/RequestHistoryItem.vala
	Widgets/RequestResponsePane.vala
	Widgets/RequestView.vala
	Widgets/ResponseStatusBar.vala
	Widgets/ResponseText.vala
	Widgets/ResponseView.vala
	Widgets/UrlEntry.vala

# tell what libraries to use when compiling
PACKAGES
	gtk+-3.0
	glib-2.0
	gio-unix-2.0
	gee-0.8
	granite
	gtksourceview-3.0
	webkit2gtk-4.0
	json-glib-1.0
)

# tell cmake what to call the executable we just made
add_executable(${EXEC_NAME} ${VALA_C})

configure_file (
    ${CMAKE_SOURCE_DIR}/src/config.vala.cmake
    ${CMAKE_SOURCE_DIR}/src/config.vala)

# install the binaries we just made
install (TARGETS ${EXEC_NAME} RUNTIME DESTINATION bin)
