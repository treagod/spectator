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
    public class Request {
        // Models
        private Gee.ArrayList<Models.Request> items;
        public Models.Request? active_request;
        // \Models
        // Views
        public Widgets.Content content { get; private set; }
        public Widgets.HeaderBar headerbar { get; private set; }
        // \Views
        public unowned Main main;
        private Services.RequestAction action;

        public signal void preference_clicked ();

        public Request (Widgets.HeaderBar headerbar, Widgets.Content content) {
            this.content = content;
            this.headerbar = headerbar;
            this.items = new Gee.ArrayList<Models.Request> ();

            setup ();
        }

        private void setup () {
            content.welcome_activated.connect (main.show_create_request_dialog);
            headerbar.new_request.clicked.connect (main.show_create_request_dialog);
            headerbar.preference_clicked.connect (() => { preference_clicked (); });

            content.url_changed.connect ((url) => {
                var uri = new Soup.URI (url);

                if (active_request != null) {
                    var old_query = active_request.query;

                    if ((uri == null || old_query != uri.query)) {
                        active_request.uri = url;
                        content.update_url_params (active_request);
                    }
                }
            });

            content.url_params_updated.connect ((items) => {
                var query_builder = new StringBuilder ();

                for (int i = 0; i < items.size; i++) {
                    var item = items.get (i);

                    if (item.key == "" && item.val == "") {
                        continue;
                    }
                    query_builder.append ("%s=%s".printf (item.key, item.val));

                    if (i < items.size - 1) {
                        query_builder.append ("&");
                    }
                }

                var querystr = query_builder.str;
                active_request.query = querystr;

                if (querystr == "") {
                    active_request.uri = active_request.uri.replace ("?", "");
                }

                main.update_active (active_request);
                // TODO: more hiearchy, so this change does not propagate that high
                content.update_url_bar (active_request.uri);
            });

            content.body_buffer_changed.connect ((content) => {
                active_request.request_body.raw = content;
            });

            content.script_changed.connect ((script) => {
                active_request.script_code = script;
            });

            content.method_changed.connect ((method) => {
                main.update_sidebar_active_method (method);
            });

            content.key_value_added.connect ((kv) => {
                active_request.request_body.add_key_value (kv);
            });

            content.key_value_updated.connect ((kv) => {
                active_request.request_body.update_key_value (kv);
            });

            content.key_value_removed.connect ((kv) => {
                active_request.request_body.remove_key_value (kv);
            });

            content.type_changed.connect ((type) => {
                active_request.request_body.type = type;
            });

            content.request_activated.connect (() => {
                active_request.status = Models.RequestStatus.SENDING;

                action = new Services.RequestAction.with_writer (active_request, content.get_console_writer ());

                action.finished_request.connect (() => {
                    if (action.item == active_request) {
                        content.update_response (active_request);
                        content.update_status (active_request);
                    }
                });

                action.request_failed.connect ((item) => {
                    action.item.status = Models.RequestStatus.SENT;
                    content.show_request (action.item);
                    content.set_error (_("Request failed: %s").printf (action.item.name));
                });

                action.invalid_uri.connect ((item) => {
                    action.item.status = Models.RequestStatus.SENT;
                    content.update_status (action.item);
                    content.set_error (_("Invalid URI: %s").printf (action.item.name));
                });

                action.proxy_failed.connect ((item) => {
                    action.item.status = Models.RequestStatus.SENT;
                    content.update_status (action.item);
                    content.set_error (_("Proxy denied request: %s").printf (action.item.name));
                });

                action.request_got_chunk.connect (() => {
                    if (action.item == active_request) {
                        content.update_chunk_response (action.item);
                    }
                });

                action.aborted.connect (() => {
                    action.item.status = Models.RequestStatus.SENT;
                    content.update_status (action.item);
                });

                action.make_request.begin ();
                active_request.last_sent = new DateTime.now_local ();
                main.update_history (active_request);
            });

            content.header_added.connect ((header) => {
                active_request.add_header (header);
            });

            content.cancel_process.connect (() => {
                if (action != null) {
                    action.cancel ();
                    action.item.status = Models.RequestStatus.SENT;
                    if (action.item == active_request) {
                        content.update_status (action.item);
                    }
                }
            });

            content.header_deleted.connect ((header) => {
                active_request.remove_header (header);
            });

            content.item_changed.connect ((request) => {
                main.set_active_sidebar_item (request);
            });
        }

        public void show_request (Models.Request request) {
            active_request = request;
            content.show_request (request);
        }

        public void add_request (Models.Request request) {
            items.add (request);
        }

        public void remove_request (Models.Request request) {
            items.remove (request);

            if (items.size == 0) {
                content.show_welcome ();
            }
        }

        public unowned Gee.ArrayList<Models.Request> get_items_reference () {
            return items;
        }
    }
}
