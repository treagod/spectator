project('com.github.treagod.spectator', 'vala', 'c')

cc = meson.get_compiler('c')
c_deps = cc.find_library('m', required: true)
c_deps = cc.find_library('duktape', required: true)

i18n = import('i18n')

dependencies = [
    dependency('gtk+-3.0'),
    dependency('glib-2.0'),
    dependency('gio-unix-2.0'),
    dependency('gee-0.8'),
    dependency('granite'),
    dependency('gtksourceview-4'),
    dependency('webkit2gtk-4.0'),
    dependency('json-glib-1.0'), # Deprecated
    dependency('libxml-2.0'),
    dependency('sqlite3'),
    dependency('libhandy-1', version: '>=0.90.0'),
    c_deps
]


gnome = import('gnome')
asresources = gnome.compile_resources(
    'as-resources', 'data/assets.gresource.xml',
    source_dir: 'data',
    c_name: 'as'
)

add_global_arguments('-DGETTEXT_PACKAGE="@0@"'.format (meson.project_name()), language:'c')

subdir('src')
subdir('data')
subdir('po')

executable(
    meson.project_name(),
    sources,
    asresources,
    config_header,
    sql_init_header,
    dependencies: dependencies,
    install: true
)


meson.add_install_script('meson/post_install.py')
