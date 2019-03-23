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

namespace Spectator.Widgets {
    class RequestResponsePane : Gtk.Paned, Request.Interface {
        private Request.Container request_view;
        private Response.Container response_view;
        private Gee.HashMap<Models.Request, int> tab_indecies;
        private Gee.HashMap<Models.Request, ResponseViewCache> cache;
        private Models.Request last_item;

        public signal void type_changed (RequestBody.ContentType type);
        public signal void body_buffer_changed (string content);
        public signal void script_changed (string script);
        public signal void key_value_added (Pair item);
        public signal void key_value_removed (Pair item);
        public signal void key_value_updated (Pair item);


        public RequestResponsePane () {
            request_view  = new Request.Container ();
            response_view = new Response.Container ();
            tab_indecies = new Gee.HashMap<Models.Request, int> ();
            cache = new Gee.HashMap<Models.Request, ResponseViewCache>();

            request_view.response_received.connect ((res) => {
                response_view.update (res);
            });

            request_view.url_params_updated.connect ((items) => {
                url_params_updated (items);
            });

            request_view.url_changed.connect ((url) => {
                url_changed (url);
            });

            request_view.cancel_process.connect (() => {
                cancel_process ();
            });

            request_view.body_buffer_changed.connect ((content) => {
                body_buffer_changed (content);
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

            request_view.script_changed.connect ((script) => {
                script_changed (script);
            });

            request_view.header_deleted.connect ((header) => {
                header_deleted (header);
            });

            request_view.type_changed.connect ((type) => {
                type_changed (type);
            });

            request_view.key_value_added.connect((item) => {
                key_value_added (item);
            });

            request_view.key_value_updated.connect((item) => {
                key_value_updated (item);
            });

            request_view.key_value_removed.connect((item) => {
                key_value_removed (item);
            });

            pack1 (request_view, true, false);
        }

        public void update_url_bar (string uri) {
            request_view.update_url_bar (uri);
        }

        public void update_url_params (Models.Request item) {
            request_view.update_url_params (item);
        }

        public Services.ScriptWriter get_console_writer () {
            return request_view.get_console_writer ();
        }

        private void adjust_tab (Models.Request item) {
            tab_indecies[last_item] = request_view.tab_index;
            last_item = item;
            request_view.set_item (item);
            if (!tab_indecies.has_key (item)) {
                request_view.tab_index = 0;
                tab_indecies[item] = 0;
            } else {
                request_view.tab_index = tab_indecies[item];
            }
        }

        private void create_or_get_cached_view (Models.Request item) {
            remove (response_view);

            if (cache.has_key(item)) {
                response_view = cache[item].view;
                response_view.show_all ();
            } else {
                response_view = new Response.Container ();
                cache[item] = new ResponseViewCache (item.response, response_view);
                response_view.show_all ();
                response_view.update (item.response);
            }

            pack2 (response_view, true, false);
            show_all ();

            if (cache[item].response != item.response) {
                cache[item].response = item.response;
                response_view.update (item.response);
            }
        }

        public void set_item (Models.Request request) {
            adjust_tab (request);
            update_response (request);
        }

        public void set_script_error (string error) {
            request_view.set_script_error (error);
        }

        public void update_response (Models.Request request) {
            if (request.response != null) {
                create_or_get_cached_view (request);
            } else {
                if (get_child2 () != null) {
                    remove (response_view);
                }
            }
        }

        public void update_status (Models.Request request) {
            request_view.update_status (request);
        }

        construct {
            orientation = Gtk.Orientation.HORIZONTAL;
        }

        private class ResponseViewCache {
            public ResponseItem response;
            public Response.Container view;

            public ResponseViewCache (ResponseItem i, Response.Container v) {
                response = i;
                view = v;
            }
        }
    }
}
