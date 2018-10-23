# files we want to compile
include(ValaPrecompile)
vala_precompile(VALA_C ${EXEC_NAME}
	Application.vala
	Window.vala

	Models/Header.vala
	Models/RequestItem.vala
	Models/ResponseItem.vala

	Controllers/RequestController.vala
	Controllers/MainController.vala
	Controllers/ReqController.vala

	Views/RequestView.vala

	Stores/RequestStore.vala

	Plugins/Engine.vala
	Plugins/Plugin.vala
	Plugins/Utils.vala

	Services/Settings.vala
	Services/RequestAction.vala

	Dialogs/Request/Dialog.vala
	Dialogs/Request/CreateDialog.vala
	Dialogs/Request/UpdateDialog.vala
	Dialogs/Alert.vala

	Widgets/Content.vala
	Widgets/HeaderBar.vala
	Widgets/Preferences.vala
	Widgets/Sidebar/Container.vala
	Widgets/Sidebar/Item.vala
	Widgets/RequestResponsePane.vala

	Widgets/Response/SourceView.vala
	Widgets/Response/Container.vala
	Widgets/Response/AbstractTypeView.vala
	Widgets/Response/HtmlView.vala
	Widgets/Response/JsonView.vala
	Widgets/Response/JsonTreeView.vala

	Widgets/Response/StatusBar/Container.vala

	Widgets/Request/Container.vala
	Widgets/Request/UrlEntry.vala
	Widgets/Request/HeaderField.vala
	Widgets/Request/HeaderView.vala
	Widgets/Request/BodyView.vala

	config.vala

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
CUSTOM_VAPIS
	Duktape/duktape.vapi
)

# tell cmake what to call the executable we just made
add_executable(${EXEC_NAME} ${VALA_C})

target_link_libraries(${EXEC_NAME} m)
target_link_libraries(${EXEC_NAME} duktape)

configure_file (
    ${CMAKE_SOURCE_DIR}/src/config.vala.cmake
    ${CMAKE_SOURCE_DIR}/src/config.vala)

# install the binaries we just made
install (TARGETS ${EXEC_NAME} RUNTIME DESTINATION bin)
