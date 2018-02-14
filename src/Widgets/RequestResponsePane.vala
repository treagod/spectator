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

namespace HTTPInspector {
    class RequestResponsePane : Gtk.Paned {
        private RequestView request_view;
        private ResponseView response_view;

        public signal void item_changed (RequestItem item);

        public RequestResponsePane () {
            request_view  = new RequestView ();
            response_view = new ResponseView ();

            request_view.item_changed.connect((item) => {
                item_changed (item);
            });

            request_view.response_received.connect ((res) => {
                response_view.update (res);
            });

            add1 (request_view);
            add2 (response_view);
        }

        public void set_item (RequestItem item) {
            if (request_view.get_item () != item) {
                request_view.set_item (item);
                response_view.update (item.response);
            }

        }

        construct {
            orientation = Gtk.Orientation.HORIZONTAL;
        }
    }
}
