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
    public class UpdateDialog : Dialog {
        public signal void updated (Models.Request item);

        public UpdateDialog (Gtk.ApplicationWindow parent, Models.Request item, Gee.ArrayList<Models.Collection> collections) {
            base (_("Update Request"), parent);
            request_name_entry.text = item.name;
            method_box.active = item.method.to_i ();

            request_name_entry.activate.connect (() => {
                update_request (item);
            });

            add_button (_("Update"), Gtk.ResponseType.APPLY);
            var content = get_content_area () as Gtk.Box;
            var combo_box = new Gtk.ComboBoxText ();
            var combo_container = new Gtk.Box (Gtk.Orientation.VERTICAL, 5);
            var collection_label = new Gtk.Label (_("Change collection"));
            collection_label.halign = Gtk.Align.START;
            combo_container.pack_start (collection_label);
            var counter = 0;
            foreach (var collection in collections) {
                combo_box.append (collection.name, collection.name);

                // Preselectes the collection which the request belongs to
                if (item.collection_id == collection.id) {
                    combo_box.active = counter;
                }
                counter++;
            }

            combo_container.pack_start (combo_box);
            content.add (combo_container);

            response.connect ((source, id) => {
                var selected_collection = collections.get (combo_box.active);

                // If the selected collection id is no more equal to the items collection id
                // we have to change the relation of the request
                if (selected_collection.id != item.collection_id) {
                    // Get current collecton which the request belongs to and remove it
                    collections.foreach ((collection) => {
                        if (collection.id != item.collection_id) return true; // Continue

                        collection.remove_request (item);
                        return false;
                    });

                    selected_collection.add_request (item);
                }
                switch (id) {
                case Gtk.ResponseType.APPLY:
                    update_request (item);
                    break;
                case Gtk.ResponseType.CLOSE:
                    destroy ();
                    break;
                }
            });
        }

        private void update_request (Models.Request item) {
            var name = request_name_entry.text;

            if (name.length == 0) {
                show_warning (_("Request name must not be empty."));
            } else {
                item.name = request_name_entry.text;
                item.method = Models.Method.convert (method_box.active);
                updated (item);
                destroy ();
            }
        }
    }
}
