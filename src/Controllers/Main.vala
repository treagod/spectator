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

namespace Spectator.Controllers {
    public class Main {
        private Request request_controller;
        private Collection collection_controller;
        public unowned Gtk.ApplicationWindow window;
        private string setting_file_path;

        public Main (Gtk.ApplicationWindow window, Request req_controller, Collection col_controller) {
            this.window = window;
            this.request_controller = req_controller;
            this.request_controller.main = this;
            this.collection_controller = col_controller;
            this.collection_controller.main = this;
            this.setting_file_path = Path.build_filename (Environment.get_home_dir (), ".local", "share",
                                                          Constants.PROJECT_NAME, "tmp_settings.json");

            setup ();
        }

        private void setup () {
            request_controller.preference_clicked.connect (() => {
                open_preferences ();
            });
        }

        private void open_preferences () {
            var dialog = new Dialogs.Preferences (window);
            dialog.show_all ();
        }

        public void add_request (Models.Request item) {
            request_controller.add_item (item);
        }

        public void add_collection (Models.Collection collection) {
            collection_controller.add_collection (collection);
        }

        public void load_data () {
            var deserializer = new Services.JsonDeserializer ();
            deserializer.request_loaded.connect ((request) => {
                add_request (request);
            });

            deserializer.collection_loaded.connect ((collection) => {
                add_collection (collection);
            });

            deserializer.request_added_to_collection.connect ((collection, request) => {
                collection_controller.add_request_to_collection (collection, request);
            });

            deserializer.load_data_from_file (setting_file_path);
        }

        public void save_data () {
            var serializer = new Services.JsonSerializer ();
            serializer.serialize (request_controller.get_items_reference (), collection_controller.get_collections ());
            serializer.write_to_file (setting_file_path);
        }
    }
}
