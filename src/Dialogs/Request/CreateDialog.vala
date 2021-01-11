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
    public class CreateDialogNew : Dialog {
        public signal void creation (Models.Request request);
        public signal void collection_created (Models.Collection collection);

        public CreateDialogNew (Spectator.Window parent) {
            base (_("Create Request"), parent);
            request_name_entry.text = _("My Request");

            add_button (_("Create"), Gtk.ResponseType.APPLY);

            request_name_entry.activate.connect (() => {
                create_request ();
            });

            response.connect ((source, id) => {
                switch (id) {
                case Gtk.ResponseType.APPLY:
                    create_request ();

                    break;
                case Gtk.ResponseType.CLOSE:
                    destroy ();
                    break;
                }
            });
        }

        private void create_request () {
            var name = request_name_entry.text;

            if (name.length == 0) {
                show_warning (_("Request name must not be empty."));
            } else {
                var index = method_box.get_active ();
                var request = new Models.Request ();
                request.name = name;
                request.method = Models.Method.convert (index);
                creation (request);
                destroy ();
            }
        }
    }
}
