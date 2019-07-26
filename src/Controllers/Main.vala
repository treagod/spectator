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
        public Sidebar sidebar_controller { get; private set; }
        private string setting_file_path;

        private Widgets.HeaderBar headerbar;
        public Window window { get; private set; }

        private void setup_keyboard_shortcuts () {
            var accel_group = new Gtk.AccelGroup ();
            accel_group.connect(Gdk.keyval_from_name("n"), Gdk.ModifierType.CONTROL_MASK, 0, () => {
                show_create_request_dialog ();
                return true;
            });

            accel_group.connect(Gdk.keyval_from_name("n"), Gdk.ModifierType.CONTROL_MASK | Gdk.ModifierType.SHIFT_MASK, 0, () => {
                var dialog = new Dialogs.Collection.CollectionDialog (window);
                dialog.show_all ();
                dialog.creation.connect ((collection) => {
                    sidebar_controller.add_collection (collection);
                });
                return true;
            });

            accel_group.connect(Gdk.Key.comma, Gdk.ModifierType.CONTROL_MASK, 0, () => {
                open_preferences ();
                return true;
            });

            accel_group.connect(Gdk.keyval_from_name("h"), Gdk.ModifierType.CONTROL_MASK, 0, () => {
                sidebar_controller.show_history ();
                return true;
            });

            accel_group.connect(Gdk.keyval_from_name("l"), Gdk.ModifierType.CONTROL_MASK, 0, () => {
                sidebar_controller.show_collection ();
                return true;
            });

            window.add_accel_group (accel_group);
        }

        public Main (Application application) {
            window = new Window (application);
            headerbar = new Widgets.HeaderBar ();
            setup_keyboard_shortcuts ();

            request_controller = new Controllers.Request (this);
            sidebar_controller = new Sidebar (this);
            setting_file_path = Path.build_filename (Environment.get_home_dir (), ".local", "share",
                                                          Constants.PROJECT_NAME, "tmp_settings.json");

            request_controller.content.show_welcome ();

            headerbar.new_request.clicked.connect (() => {
                show_create_request_dialog ();
            });

            headerbar.preference_clicked.connect (() => {
                open_preferences ();
            });

            headerbar.new_collection.clicked.connect (() => {
                var dialog = new Dialogs.Collection.CollectionDialog (window);
                dialog.show_all ();
                dialog.creation.connect ((collection) => {
                    sidebar_controller.add_collection (collection);
                });
            });

            window.close_window.connect (() => {
                save_data ();
            });

            load_data ();
        }

        public void show_app () {
            window.show_app (headerbar, sidebar_controller.sidebar, request_controller.content);
            unselect_all ();
        }

        public void update_headerbar (Models.Request request) {
            headerbar.subtitle = request.name;
        }

        public void show_create_request_dialog () {
            var dialog = new Dialogs.Request.CreateDialog (window, sidebar_controller.get_collections ());

            dialog.show_all ();
            dialog.creation.connect ((request) => {
                request.script_code = "// function before_sending(request) {\n// }";
                add_request (request);
                update_headerbar (request);
                request_controller.show_request (request);
            });
            dialog.collection_created.connect ((collection) => {
                sidebar_controller.add_collection (collection);
                collection.items_visible = true;
            });
        }

        public void update_active_url () {
            sidebar_controller.update_active_url ();
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
            sidebar_controller.remove_request (request);
        }

        public void unselect_all () {
            sidebar_controller.unselect_all ();
        }

        public void set_active_sidebar_item (Models.Request request) {
            sidebar_controller.set_active (request);
        }

        public void delete_collection (Models.Collection collection) {
            foreach (var request in collection.requests) {
                request_controller.remove_request (request);
            }
            sidebar_controller.delete_collection (collection);
        }

        public void update_sidebar_active_method (Models.Method method) {
            sidebar_controller.update_method_active (method);
        }

        public void show_content (Models.Request request) {
            request_controller.show_request (request);
        }

        public void add_collection (Models.Collection collection) {
            sidebar_controller.add_collection (collection);
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
                sidebar_controller.add_request_to_collection (collection, request);
            });

            deserializer.collection_loaded.connect ((collection) => {
                add_collection (collection);
            });

            deserializer.load_data_from_file (setting_file_path);

            var requests = request_controller.get_items_reference ();
            sidebar_controller.add_history_from_list (requests);
        }

        public void save_data () {
            var serializer = new Services.JsonSerializer ();
            serializer.serialize (request_controller.get_items_reference (), sidebar_controller.get_collections ());
            serializer.write_to_file (setting_file_path);
        }
    }
}
