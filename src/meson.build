conf_data = configuration_data()
conf_data.set('PROJECT_NAME', meson.project_name())
conf_data.set('EXEC_NAME', meson.project_name())
conf_data.set('DATADIR', get_option('datadir'))
conf_data.set('PKGDATADIR', get_option('datadir') + '/' + meson.project_name())
conf_data.set('GETTEXT_PACKAGE', meson.project_name())
conf_data.set('RELEASE_NAME', 'Spectator')
<<<<<<< HEAD
conf_data.set('VERSION', '0.4.0')
=======
conf_data.set('VERSION', '0.3.1')
>>>>>>> c7c97f374ff324097bde7d86429153d7ff14b1e2
conf_data.set('VERSION_INFO', 'Preview')
conf_data.set('PREFIX', get_option('prefix'))

config_header = configure_file(
    input: 'config.vala.in',
    output: 'config.vala',
    configuration: conf_data
)

executable(
    meson.project_name(),
    'Application.vala',
	'Window.vala',
	'Models/Pair.vala',
	'Models/Collection.vala',
	'Models/Request.vala',
    'Models/RequestBody.vala',
	'Models/ResponseItem.vala',
    'Models/Script.vala',
	'Controllers/Request.vala',
	'Controllers/Main.vala',
	'Controllers/Collection.vala',
	'Controllers/Sidebar.vala',
	'Controllers/History.vala',
	'Services/Utilities.vala',
    'Services/ScriptWriter.vala',
	'Services/Settings.vala',
	'Services/JsonSerializer.vala',
	'Services/JsonDeserializer.vala',
    'Services/ScriptContext.vala',
	'Services/RequestAction.vala',
    'Services/Scripting/Http.vala',
    'Services/Scripting/Console.vala',
    'Services/Scripting/Helper.vala',
	'Dialogs/Request/Dialog.vala',
	'Dialogs/Request/CreateDialog.vala',
	'Dialogs/Request/CreateDialogWithCollection.vala',
	'Dialogs/Request/UpdateDialog.vala',
	'Dialogs/Collection/CreateCollection.vala',
	'Dialogs/Collection/UpdateCollection.vala',
	'Dialogs/Alert.vala',
	'Dialogs/Preferences.vala',
	'Dialogs/Preference/General.vala',
	'Dialogs/Preference/Network.vala',
	'Dialogs/Preference/Editor.vala',
	'Widgets/Content.vala',
	'Widgets/HeaderBar.vala',
	'Widgets/Sidebar/Container.vala',
	'Widgets/Sidebar/Item.vala',
	'Widgets/Sidebar/History/Container.vala',
	'Widgets/Sidebar/Collection/Container.vala',
	'Widgets/Sidebar/Collection/Dropdown.vala',
	'Widgets/RequestResponsePane.vala',
	'Widgets/Response/SourceView.vala',
	'Widgets/Response/Container.vala',
	'Widgets/Response/AbstractTypeView.vala',
	'Widgets/Response/HtmlView.vala',
	'Widgets/Response/DefaultView.vala',
	'Widgets/Response/XmlView.vala',
    'Widgets/Response/XmlTreeView.vala',
	'Widgets/Response/JsonView.vala',
	'Widgets/Response/JsonTreeView.vala',
    'Widgets/Response/HeaderList.vala',
	'Widgets/Response/StatusBar/Container.vala',
	'Widgets/Request/Container.vala',
	'Widgets/Request/UrlEntry.vala',
	'Widgets/Request/HeaderField.vala',
	'Widgets/Request/BodyView.vala',
	'Widgets/Request/Scripting/Container.vala',
	'Widgets/Request/Scripting/SourceView.vala',
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
        dependency('libxml-2.0'),
        c_deps
    ],
    install: true
)
