/*
* Copyright (c) 2018 Marvin Ahlgrimm (https://github.com/treagod)
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

namespace HTTPInspector {
    public class Window : Gtk.ApplicationWindow, View.Request {
        private Content content;
        private RequestHistory request_history;
        private RequestController request_controller;

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

            // Show the app
            show_app ();
        }

        public void show_app () {
            var grid = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
            grid.width_request = 950;
            grid.height_request = 500;

            var headerbar = new HeaderBar ();
            headerbar.new_request.clicked.connect (() => {
                create_request ();
            });
            headerbar.preference_clicked.connect (() => {
                open_preferences ();
            });
            set_titlebar (headerbar);

            var seperator = new Gtk.Separator (Gtk.Orientation.VERTICAL);
            seperator.visible = true;
            seperator.no_show_all = false;

            request_controller = new RequestController ();
            content = new Content (request_controller);
            request_history = new RequestHistory (request_controller);

            request_controller.register_view (this);

            content.welcome_activated.connect ((index) => {
                create_request ();
            });

            content.item_changed.connect ((item) => {
                request_history.update_active (item);
            });

            selected_item_updated.connect (() => {
                headerbar.subtitle = request_controller.selected_item.name;
                content.show_request_view (request_controller.selected_item);
            });

            grid.add (request_history);
            grid.add (seperator);
            add (grid);
            grid.add (content);
            show_all ();
            show ();
            present ();
        }

        private void create_request () {
            var dialog = new RequestDialog (this);
            dialog.show_all ();
            dialog.creation.connect ((item) => {
                request_controller.add_request (item);
            });
        }

        private void open_preferences () {
            var dialog = new Preferences (this);
            dialog.show_all ();
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

            return false;
        }
    }
}
