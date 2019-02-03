# Spectator

![Screenshot](data/screenshot.png?raw=true)

## Building, Testing, and Installation

You'll need the following dependencies:
* cmake
* libgee-0.8-dev
* libgranite-dev
* libgtksourceview-3.0-dev
* libwebkit2gtk-4.0-dev
* libjson-glib-dev
* duktape-dev
* valac

Run `meson build` to configure the build environment. Change to the build directory and run `ninja test` to build

    meson build --prefix=/usr
    cd build
    ninja test

To install, use `ninja install`, then execute with `com.github.treagod.spectator`

    sudo ninja install
    com.github.treagod.spectator
