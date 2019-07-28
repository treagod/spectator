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

namespace Spectator.Dialogs.Request {
    public class CreateDialog : Dialog {
        public signal void creation (Models.Request request);
        public signal void collection_created (Models.Collection collection);

        public CreateDialog (Gtk.ApplicationWindow parent, Gee.ArrayList<Models.Collection> collections) {
            base (_("Create Request"), parent);
            request_name_entry.text = _("My Request");

            add_button (_("Create"), Gtk.ResponseType.APPLY);
            var content = get_content_area () as Gtk.Box;

            var combo_box = new Gtk.ComboBoxText ();

            if (collections.size > 0) {
                var combo_container = new Gtk.Box (Gtk.Orientation.VERTICAL, 5);
                var collection_label = new Gtk.Label (_("Add to collection"));
                collection_label.halign = Gtk.Align.START;
                combo_container.pack_start (collection_label);
                foreach (var collection in collections) {
                    combo_box.append (collection.name, collection.name);
                }

                combo_container.pack_start (combo_box);
                combo_box.active = 0;
                content.add (combo_container);
            }

            var new_collection = _("New Collection");

            request_name_entry.activate.connect (() => {
                if (collections.size > 0) {
                    var collection = collections.get (combo_box.active);
                    create_request (collection);
                } else {
                    // TODO: temporary create new collection if none exists
                    // Future: Add request to top level in view
                    var collection = new Models.Collection (new_collection);
                    collection_created (collection);
                    create_request (collection);
                }
            });

            response.connect ((source, id) => {
                switch (id) {
                case Gtk.ResponseType.APPLY:
                    if (collections.size > 0) {
                        var collection = collections.get (combo_box.active);
                        create_request (collection);
                    } else {
                        // TODO: temporary create new collection if none exists
                        // Future: Add request to top level in view
                        var collection = new Models.Collection (new_collection);
                        collection_created (collection);
                        create_request (collection);
                    }

                    break;
                case Gtk.ResponseType.CLOSE:
                    destroy ();
                    break;
                }
            });
        }

        private void create_request (Models.Collection collection) {
            var name = request_name_entry.text;

            if (name.length == 0) {
                show_warning (_("Request name must not be empty."));
            } else {
                var index = method_box.get_active ();
                var request = new Models.Request (name, Models.Method.convert (index));
                collection.add_request (request);
                creation (request);
                destroy ();
            }
        }
    }
}
