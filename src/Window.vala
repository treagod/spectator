/*
* Copyright (c) 2019 Marvin Ahlgrimm (https://github.com/treagod)
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 2 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*
* Authored by: Marvin Ahlgrimm <marv.ahlgrimm@gmail.com>
*/

namespace Spectator {
    public class Window : Gtk.ApplicationWindow {
        public signal void close_window ();
        public Window (Gtk.Application app) {
            var settings = Settings.get_instance ();
            // Store the main app to be used
            Object (application: app);

            Gtk.Settings.get_default ().gtk_application_prefer_dark_theme = settings.dark_theme;
            move (settings.pos_x, settings.pos_y);
            resize (settings.window_width, settings.window_height);

            if (settings.maximized) {
                maximize ();
            }
        }

        public void show_app (Widgets.HeaderBar headerbar, Widgets.Sidebar.Container sidebar, Widgets.Content content) {
            var provider = new Gtk.CssProvider ();
            provider.load_from_resource ("/com/github/treagod/spectator/stylesheet.css");
            Gtk.StyleContext.add_provider_for_screen (Gdk.Screen.get_default (),
                                                      provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

            var paned = new Gtk.Paned (Gtk.Orientation.HORIZONTAL);
            paned.wide_handle = true;

            set_titlebar (headerbar);

            show_all ();

            paned.pack1 (sidebar, false, false);
            paned.pack2 (content, false, false);
            add (paned);

            show_all ();
        }

        protected override bool delete_event (Gdk.EventAny event) {
            var settings = Settings.get_instance ();
            int width, height, x, y;

            get_size (out width, out height);
            get_position (out x, out y);

            settings.pos_x = x;
            settings.pos_y = y;
            settings.window_width = width;
            settings.window_height = height;
            settings.maximized = is_maximized;

            //controller.save_data ();

            close_window ();

            return false;
        }
    }
}
