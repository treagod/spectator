# Spectator

Spectator is a native application written in Vala using GTK. It's enables you to test the
API endpoints of your HTTP server.

![Screenshot GET JSON](screenshots/Screenshot from 2019-03-14 21.56.17@2x.png)

## Features

- [x] Do requests to a web server
- [x] Handle Basic Proxy Server
- [ ] Create request enviroments
- [ ] Create collections of requests
- [ ] Create test enviroments for your collections

Right now Spectator allows you to make single requests to a web endpoint. In the long run
it shall give you to give you the ability to create enviroments and collections to make
your workflow more fluent.

## Building, Testing, and Installation

You'll need the following dependencies:
* meson
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

## Git Policy

As of 11th March 2019 a new [git policy](https://nvie.com/posts/a-successful-git-branching-model/) should be used.
