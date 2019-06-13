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
    public class Sidebar {
        public Main main { get; private set; }

        public Widgets.Sidebar.Container sidebar { get; private set; }
        public Sidebar (Main m) {
            main = m;
            sidebar = main.window.sidebar;

            setup ();
        }

        private void setup () {
            sidebar.item_edited.connect (main.show_update_request_dialog);

            sidebar.selection_changed.connect ((request) => {
                main.update_headerbar (request);
                main.show_content (request);
            });

            sidebar.create_collection_request.connect ((collection) => {
                var dialog = new Dialogs.Request.CreateDialogWithCollection (main.window, collection);
                dialog.show_all ();
                dialog.creation.connect ((request) => {
                    request.script_code = "// function before_sending(request) {\n// }";
                    main.add_request (request);
                    main.update_headerbar (request);
                    main.show_content (request);
                });
            });

            sidebar.item_deleted.connect ((request) => {
                main.remove_request (request);
            });

            sidebar.collection_edit.connect ((collection) => {
                var dialog = new Dialogs.Collection.UpdateCollectionDialog (main.window, collection);
                dialog.show_all ();
                dialog.updated.connect (() => {
                    sidebar.update_collection (collection);
                });
            });
        }

        public void adjust_visibility () {
            sidebar.adjust_visibility ();
        }

        public void set_active (Models.Request request) {
            sidebar.update_active (request);
        }

        public void update_method_active (Models.Method method) {
            sidebar.update_active_method (method);
        }

        public void add_request (Models.Request request) {
            sidebar.add_item (request);
        }
    }
}