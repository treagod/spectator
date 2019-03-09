conf_data = configuration_data()
conf_data.set('PROJECT_NAME', meson.project_name())
conf_data.set('EXEC_NAME', meson.project_name())
conf_data.set('DATADIR', get_option('datadir'))
conf_data.set('PKGDATADIR', get_option('datadir') + '/' + meson.project_name())
conf_data.set('GETTEXT_PACKAGE', meson.project_name())
conf_data.set('RELEASE_NAME', 'Spectator')
conf_data.set('VERSION', '0.1.0')
conf_data.set('VERSION_INFO', 'Initial release')
conf_data.set('PREFIX', get_option('prefix'))

config_header = configure_file(
    input: 'config.vala.in',
    output: 'config.vala',
    configuration: conf_data
)

executable(
    meson.project_name(),
    'Application.vala',
    'Application.vala',
	'Window.vala',
	'Models/Pair.vala',
	'Models/Collection.vala',
	'Models/RequestItem.vala',
    'Models/RequestBody.vala',
	'Models/ResponseItem.vala',
	'Controllers/Request.vala',
	'Controllers/Main.vala',
	'Controllers/Collection.vala',
	'Stores/RequestStore.vala',
	'Plugins/Engine.vala',
	'Plugins/Plugin.vala',
	'Plugins/Utils.vala',
	'Services/Settings.vala',
	'Services/JsonSerializer.vala',
	'Services/JsonDeserializer.vala',
	'Services/RequestAction.vala',
	'Dialogs/Request/Dialog.vala',
	'Dialogs/Request/CreateDialog.vala',
	'Dialogs/Request/UpdateDialog.vala',
	'Dialogs/Alert.vala',
	'Dialogs/Preferences.vala',
	'Dialogs/Preference/General.vala',
	'Dialogs/Preference/Network.vala',
	'Widgets/Content.vala',
	'Widgets/HeaderBar.vala',
	'Widgets/Sidebar/Container.vala',
	'Widgets/Sidebar/Item.vala',
	'Widgets/RequestResponsePane.vala',
	'Widgets/Response/SourceView.vala',
	'Widgets/Response/Container.vala',
	'Widgets/Response/AbstractTypeView.vala',
	'Widgets/Response/HtmlView.vala',
	'Widgets/Response/JsonView.vala',
	'Widgets/Response/JsonTreeView.vala',
    'Widgets/Response/HeaderList.vala',
	'Widgets/Response/StatusBar/Container.vala',
	'Widgets/Request/Container.vala',
	'Widgets/Request/UrlEntry.vala',
	'Widgets/Request/HeaderField.vala',
	'Widgets/Request/BodyView.vala',
    'Widgets/Request/BodySourceView.vala',
    'Widgets/Request/KeyValueList.vala',
    'Widgets/Request/KeyValueField.vala',
    'Widgets/Request/Interface.vala',
    'Widgets/Request/ItemProvider.vala',
    'Widgets/Request/HeaderProvider.vala',
    'Duktape/duktape.vapi',
    asresources,
    config_header,
    dependencies: [
        dependency('gtk+-3.0'),
        dependency('glib-2.0'),
        dependency('gio-unix-2.0'),
        dependency('gee-0.8'),
        dependency('granite'),
        dependency('gtksourceview-3.0'),
        dependency('webkit2gtk-4.0'),
        dependency('json-glib-1.0'),
        c_deps
    ],
    install: true
)
