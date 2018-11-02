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

namespace HTTPInspector.Widgets {
    class RequestResponsePane : Gtk.Paned, Request.Interface {
        private Request.Container request_view;
        private Response.Container response_view;

        public signal void item_changed (RequestItem item);

        public RequestResponsePane () {
            request_view  = new Request.Container ();
            response_view = new Response.Container ();

            request_view.response_received.connect ((res) => {
                response_view.update (res);
            });

            request_view.url_params_updated.connect ((items) => {
                url_params_updated (items);
            });

            request_view.url_changed.connect ((url) => {
                url_changed (url);
            });

            request_view.request_activated.connect (() => {
                request_activated ();
            });

            request_view.method_changed.connect ((method) => {
                method_changed (method);
            });

            request_view.header_added.connect ((header) => {
                header_added (header);
            });

            request_view.header_deleted.connect ((header) => {
                header_deleted (header);
            });

            pack1 (request_view, true, false);
        }

        public void update_url_bar (string uri) {
            request_view.update_url_bar (uri);
        }

        public void update_url_params (RequestItem item) {
            request_view.update_url_params (item);
        }

        public void set_item (RequestItem item) {
            request_view.set_item (item);
            if (item.response != null) {
                response_view.update (item.response);
                if (get_child2 () == null) {
                    pack2 (response_view, true, false);
                    show_all ();
                }
            } else {
                if (get_child2 () != null) {
                    remove (response_view);
                }
            }

        }

        construct {
            orientation = Gtk.Orientation.HORIZONTAL;
        }
    }
}
