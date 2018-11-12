project('com.github.treagod.spectator', 'vala', 'c')

cc = meson.get_compiler('c')
c_deps = cc.find_library('m', required: true)
c_deps = cc.find_library('duktape', required: true)

i18n = import('i18n')

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

meson.add_install_script('meson/post_install.py')