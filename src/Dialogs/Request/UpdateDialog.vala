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

namespace HTTPInspector.Dialogs.Request {
    public class UpdateDialog : Dialog {
        public signal void updated (RequestItem item);

        public UpdateDialog (Gtk.ApplicationWindow parent, RequestItem item) {
            base (_("Update Request"), parent);
            request_name_entry.text = item.name;
            method_box.active = item.method.to_i ();

            request_name_entry.activate.connect (() => {
                update_request (item);
            });

            add_button (_("Update"), Gtk.ResponseType.APPLY);

            response.connect ((source, id) => {
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

        private void update_request (RequestItem item) {
            var name = request_name_entry.text;

            if (name.length == 0) {
                show_warning (_("Request name must not be empty."));
            } else {
                item.name = request_name_entry.text;
                item.method = Method.convert (method_box.active);
                updated (item);
                destroy ();
            }
        }
    }
}
