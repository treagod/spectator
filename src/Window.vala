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
    public class Window : Gtk.ApplicationWindow {
        private Widgets.Content request_item_view;
        private Widgets.Sidebar.Container sidebar;
        private Controllers.MainController controller;

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

            set_titlebar (headerbar);

            var seperator = new Gtk.Separator (Gtk.Orientation.VERTICAL);
            seperator.visible = true;
            seperator.no_show_all = false;

            request_item_view = new Widgets.Content ();
            sidebar = new Widgets.Sidebar.Container ();

            var req_controller = new Controllers.RequestController (headerbar, sidebar, request_item_view);

            controller = new Controllers.MainController (this, req_controller);

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
                        var request = new RequestItem.with_uri (name, uri, Method.convert (method));
                        var headers = item.get_array_member ("headers");

                        foreach (var header_element in headers.get_elements ()) {
                            var header = header_element.get_object ();
                            request.add_header (new Pair (header.get_string_member ("key"), header.get_string_member ("value")));
                        }

                        controller.add_request (request);
                    }
                } catch (Error e) {
                    // Do something funny
                }

                request_item_view.show_welcome ();
                sidebar.clear_selection ();
            }

            grid.add (sidebar);
            grid.add (seperator);
            add (grid);
            grid.add (request_item_view);
            show_all ();
            show ();
            present ();
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
            var s = controller.serialize_data ();
            settings.data = s;

            return false;
        }
    }
}
