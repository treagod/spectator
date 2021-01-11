/*
* Copyright (c) 2021 Marvin Ahlgrimm (https://github.com/treagod)
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
        public signal void updated (string name, Models.Method method);

        public UpdateDialog (Spectator.Window parent, Models.Request request) {
            base (_("Update Request"), parent);
            request_name_entry.text = request.name;
            method_box.active = request.method.to_i ();

            request_name_entry.activate.connect (() => {
                update_request (request);
            });

            add_button (_("Update"), Gtk.ResponseType.APPLY);

            response.connect ((source, id) => {
                switch (id) {
                case Gtk.ResponseType.APPLY:
                    update_request (request);
                    break;
                case Gtk.ResponseType.CLOSE:
                    destroy ();
                    break;
                }
            });
        }

        private void update_request (Models.Request request) {
            var name = request_name_entry.text;

            if (name.length == 0) {
                show_warning (_("Request name must not be empty."));
            } else {
                updated (request_name_entry.text, Models.Method.convert (method_box.active));
                destroy ();
            }
        }
    }
}
