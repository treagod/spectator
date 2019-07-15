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
        public Request request_controller { get; private set; }
        public Collection collection_controller { get; private set; }
        public Sidebar sidebar_controller { get; private set; }
        public unowned Window window;
        private string setting_file_path;

        public Main (Window window, Request req_controller, Collection col_controller) {
            this.window = window;
            this.request_controller = req_controller;
            this.request_controller.main = this;
            this.collection_controller = col_controller;
            this.collection_controller.main = this;
            sidebar_controller = new Sidebar (this);
            this.setting_file_path = Path.build_filename (Environment.get_home_dir (), ".local", "share",
                                                          Constants.PROJECT_NAME, "tmp_settings.json");

            setup ();
        }

        public void update_headerbar (Models.Request request) {
            request_controller.headerbar.subtitle = request.name;
        }

        public void show_create_request_dialog () {
            var dialog = new Dialogs.Request.CreateDialog (window);
            dialog.show_all ();
            dialog.creation.connect ((request) => {
                request.script_code = "// function before_sending(request) {\n// }";
                add_request (request);
                update_headerbar (request);
                request_controller.show_request (request);
            });
        }

        public void update_active (Models.Request request) {
            stdout.printf ("Not implemented\n");
        }

        public void show_update_request_dialog (Models.Request request) {
           var dialog = new Dialogs.Request.UpdateDialog (window, request);
           dialog.show_all ();
           dialog.updated.connect ((request) => {
               update_headerbar (request);

               if (request == sidebar_controller.sidebar.get_active_item ()) {
                   request_controller.show_request (request);
               }
           });
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

        public void add_request (Models.Request request) {
            request_controller.add_request (request);
            sidebar_controller.add_request (request);
        }

        public void remove_request (Models.Request request) {
            request_controller.remove_request (request);
            collection_controller.remove_request (request);
        }

        public void adjust_visibility () {
            sidebar_controller.adjust_visibility ();
        }

        public void set_active_sidebar_item (Models.Request request) {
            sidebar_controller.set_active (request);
        }

        public void update_sidebar_active_method (Models.Method method) {
            sidebar_controller.update_method_active (method);
        }

        public void show_content (Models.Request request) {
            request_controller.show_request (request);
        }

        public void add_collection (Models.Collection collection) {
            collection_controller.add_collection (collection);
        }

        public void update_history (Models.Request request) {
            sidebar_controller.update_history (request);
        }

        public void load_data () {
            var deserializer = new Services.JsonDeserializer ();
            deserializer.request_loaded.connect ((request) => {
                add_request (request);
            });

            deserializer.request_added_to_collection.connect ((collection, request) => {
                collection_controller.add_request_to_collection (collection, request);
            });

            deserializer.collection_loaded.connect ((collection) => {
                add_collection (collection);
            });

            deserializer.load_data_from_file (setting_file_path);

            var requests = request_controller.get_items_reference ();
            sidebar_controller.add_test (requests);
        }

        public void save_data () {
            var serializer = new Services.JsonSerializer ();
            serializer.serialize (request_controller.get_items_reference (), collection_controller.get_collections ());
            serializer.write_to_file (setting_file_path);
        }
    }
}
