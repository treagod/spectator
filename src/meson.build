conf_data = configuration_data()
conf_data.set('PROJECT_NAME', meson.project_name())
conf_data.set('EXEC_NAME', meson.project_name())
conf_data.set('DATADIR', get_option('datadir'))
conf_data.set('PKGDATADIR', get_option('datadir') + '/' + meson.project_name())
conf_data.set('GETTEXT_PACKAGE', meson.project_name())
conf_data.set('RELEASE_NAME', 'Spectator')
conf_data.set('VERSION', '0.4.3')
conf_data.set('VERSION_INFO', 'Preview')
conf_data.set('PREFIX', get_option('prefix'))

config_header = configure_file(
    input: 'config.vala.in',
    output: 'config.vala',
    configuration: conf_data
)

sources = files(
    'Main.vala',
    'Application.vala',
	'Window.vala',
    'Duktape/duktape.vapi'
)

subdir('Controllers')
subdir('Dialogs')
subdir('Models')
subdir('Services')
subdir('Widgets')
