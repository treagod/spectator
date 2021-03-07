---
title: Installation
description: Learn how to install Spectator from source
---


<h2 class="subtitle is-2">AppCenter</h2>

The easiest way is to install Spectator from <a target="_blank" rel="noopener noreferrer" href="https://appcenter.elementary.io/com.github.treagod.spectator/">AppCenter</a>

<h2 class="subtitle is-2">Flatpak</h2>

If you're using Flatpak install it with

```bash
$ flatpak install flathub com.github.treagod.spectator
```

Then run it with

```bash
$ flatpak run com.github.treagod.spectator
```

<h2 class="subtitle is-2">Build it yourself</h2>

If you are on an Ubuntu derivate, you can build and install Spectator as follows

```bash
$ sudo apt install valac meson libgee-0.8-dev libgranite-dev \
   libgtksourceview-3.0-dev libwebkit2gtk-4.0-dev libjson-glib-dev \
   libxml2-dev duktape-dev git cmake libsqlite3-dev

$ git clone https://github.com/treagod/spectator.git
$ cd spectator
$ meson build --prefix=/usr
$ cd build
$ ninja
$ sudo ninja install
```
