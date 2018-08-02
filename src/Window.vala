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
        private Widgets.Content content;
        private Widgets.Sidebar.Container item_container;
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
            var settings = Settings.get_instance ();
            var grid = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
            grid.width_request = 950;
            grid.height_request = 500;

            var headerbar = new Widgets.HeaderBar ();
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
            content = new Widgets.Content (request_controller);
            item_container = new Widgets.Sidebar.Container (request_controller);

            request_controller.register_view (this);

            content.welcome_activated.connect ((index) => {
                create_request ();
            });

            content.item_changed.connect ((item) => {
                item_container.update_active (item);
            });

            selected_item_changed.connect (() => {
                headerbar.subtitle = request_controller.selected_item.name;
                content.show_request_view (request_controller.selected_item);
            });

            if (settings.data != "") {
                var parser = new Json.Parser ();
                try {
                    parser.load_from_data (settings.data);
                    // TODO:  Error if root is no object
                    var root = parser.get_root ();
                    var object = root.get_object ();

                    var items = object.get_member ("request_items");
                    // TODO: throw error if not an array
                    var s = items.get_array ();

                    foreach (var array_node in s.get_elements ()) {
                        var item = array_node.get_object ();
                        var name = item.get_string_member ("name");
                        var uri = item.get_string_member ("uri");
                        var method = (int) item.get_int_member ("method");
                        request_controller.add_request (new RequestItem.with_uri (name, uri, Method.convert (method)));
                    }
                } catch (Error e) {
                    // Do something funny
                }

                content.show_welcome ();
                item_container.clear_selection ();
            }

            grid.add (item_container);
            grid.add (seperator);
            add (grid);
            grid.add (content);
            show_all ();
            show ();
            present ();
        }

        private void create_request () {
            var dialog = new Widgets.RequestDialog (this);
            dialog.show_all ();
            dialog.creation.connect ((item) => {
                request_controller.add_request (item);
            });
        }

        private void open_preferences () {
            var dialog = new Widgets.Preferences (this);
            
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
            settings.data = generate_data_json_str ();

            return false;
        }

        private string generate_data_json_str () {
            Json.Builder builder = new Json.Builder ();
            builder.begin_object ();
            builder.set_member_name ("version");
            builder.add_string_value ("0.1.0");

            var items = request_controller.get_items ();

            builder.set_member_name ("request_items");
            builder.begin_array ();

            if (items.size > 0) {
                foreach (var item in items) {
                    builder.begin_object ();
                    builder.set_member_name ("name");
                    builder.add_string_value (item.name);
                    builder.set_member_name ("uri");
                    builder.add_string_value (item.uri);
                    builder.set_member_name ("method");
                    builder.add_int_value (item.method.to_i ());
                    builder.set_member_name ("headers");
                    builder.begin_array ();
                    foreach (var header in item.headers) {
                        builder.begin_object ();
                        builder.set_member_name ("key");
                        builder.add_string_value (header.key);
                        builder.set_member_name ("value");
                        builder.add_string_value (header.val);
                        builder.end_object ();
                    }
                    builder.end_array ();

                    builder.end_object ();
                }
            }

            builder.end_array ();
            builder.end_object ();

            var generator = new Json.Generator ();
            generator.set_root (builder.get_root ());

            return generator.to_data (null);
        }
    }
}
