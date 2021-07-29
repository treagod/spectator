
# Spectator
[![Build Status](https://travis-ci.com/treagod/spectator.svg?branch=master)](https://travis-ci.com/treagod/spectator)

Spectator is a native application written in Vala using GTK. It's enables you to test the
API endpoints of your HTTP server.

![Screenshot GET JSON](screenshots/screenshot1.png)

## Download

<a href="https://appcenter.elementary.io/com.github.treagod.spectator/"><img  height='80' src="https://appcenter.elementary.io/badge.svg" alt="Get it on AppCenter"></a><a href='https://flathub.org/apps/details/com.github.treagod.spectator'><img height='80' alt='Download on Flathub' src='https://flathub.org/assets/badges/flathub-badge-en.png'/></a>

## Features

- [x] Do requests to a web server
- [x] Handle Basic Proxy Server
- [x] Scripting capabilities
- [x] Create collections of requests
- [x] Create request enviroments
- [ ] Create test enviroments for your collections

Right now Spectator allows you to make single requests to a web endpoint. In the long run
it shall give you to give you the ability to create enviroments and collections to make
your workflow more fluent.

## Building, Testing, and Installation

You'll need the following dependencies:
* flatpak-builder

If you are not on elementary OS then you may also have to install the `flatpak` package before compiling.

To build and install, use `flatpak-builder`.

    flatpak-builder buildir com.github.treagod.spectator.yml --install --user --force-clean

Then you can run the app with `flatpak run com.github.treagod.spectator`.

Once you are done testing and want to remove the app, run `flatpak uninstall com.github.treagod.spectator`.

If you instead want to completely remove the both the app and its user data, run `flatpak uninstall com.github.treagod.spectator --delete-data`.

Flatpak building is the only officially supported build method, though building in the Debian format is possible via meson:

    meson build --prefix=/usr
    cd build
    ninja
    
And can then be installed with `sudo ninja install`
