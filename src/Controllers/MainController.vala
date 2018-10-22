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

namespace HTTPInspector.Controllers {
    public class MainController {
        public RequestController request_controller {
            get;
            private set;
        }

        public unowned Gtk.ApplicationWindow window;

        public MainController (Gtk.ApplicationWindow window, RequestController request_controller) {
            this.window = window;
            this.request_controller = request_controller;
            this.request_controller.main = this;

            setup ();
        }

        private void setup () {
            request_controller.preference_clicked.connect (() => {
                open_preferences ();
            });
        }

        private void open_preferences () {
            var dialog = new Widgets.Preferences (window);
            dialog.show_all ();
        }

        public void add_request (RequestItem item) {
            request_controller.add_item (item);
        }

        public string serialize_data () {
            Json.Builder builder = new Json.Builder ();
            var items = request_controller.get_items_reference ();
            builder.begin_object ();
            builder.set_member_name ("version");
            builder.add_string_value ("0.1");

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
