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
        // \Models
        // Views
        private Widgets.Sidebar.Container sidebar;
        private Widgets.Content content;
        private Widgets.HeaderBar headerbar;
        // \Views
        public Main main;
        private Services.RequestAction action;

        public signal void preference_clicked ();

        public Request (Widgets.HeaderBar headerbar, Widgets.Sidebar.Container sidebar,
                                  Widgets.Content content) {
            this.sidebar = sidebar;
            this.content = content;
            this.headerbar = headerbar;
            this.items = new Gee.ArrayList<Models.Request> ();

            setup ();
        }

        private void setup () {
            content.welcome_activated.connect (show_create_request_dialog);
            headerbar.new_request.clicked.connect (show_create_request_dialog);
            headerbar.preference_clicked.connect (() => { preference_clicked (); });
            sidebar.item_edited.connect (show_update_request_dialog);
            sidebar.selection_changed.connect ((item) => {
                update_headerbar (item);
                update_content (item);
            });

            content.url_changed.connect ((url) => {
                var request = sidebar.get_active_item ();
                var uri = new Soup.URI (url);
                var old_query = request.query;

                if (request != null) {
                    request.uri = url;

                    if ((uri == null || old_query != uri.query)) {
                        content.update_url_params (request);
                    }
                }
            });

            content.url_params_updated.connect ((items) => {
                var query_builder = new StringBuilder ();
                var request = sidebar.get_active_item ();

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
                request.query = querystr;

                if (querystr == "") {
                    request.uri = request.uri.replace("?", "");
                }

                sidebar.update_active (request);
                content.update_url_bar (request.uri);
            });

            content.body_buffer_changed.connect ((content) => {
                var item = sidebar.get_active_item ();
                item.request_body.raw = content;
            });

            content.script_changed.connect ((script) => {
                var item = sidebar.get_active_item ();
                item.script_code = script;
            });

            content.method_changed.connect ((method) => {
                sidebar.update_active_method (method);
            });

            content.key_value_added.connect((kv) => {
                var item = sidebar.get_active_item ();
                item.request_body.add_key_value (kv);
            });

            content.key_value_updated.connect((kv) => {
                var item = sidebar.get_active_item ();
                item.request_body.update_key_value (kv);
            });

            content.key_value_removed.connect((kv) => {
                var item = sidebar.get_active_item ();
                item.request_body.remove_key_value (kv);
            });

            content.type_changed.connect ((type) => {
                var item = sidebar.get_active_item ();
                item.request_body.type = type;
            });

            content.request_activated.connect (() => {
                var item = sidebar.get_active_item ();
                item.status = Models.RequestStatus.SENDING;

                action = new Services.RequestAction.with_writer (item, content.get_console_writer ());

                action.finished_request.connect (() => {
                    if (item == sidebar.get_active_item ()) {
                        content.update_response (item);
                        content.update_status (item);
                    }
                });

                action.request_failed.connect ((item) => {
                    item.status = Models.RequestStatus.SENT;
                    content.show_request (item);
                    content.set_error ("Request failed: %s".printf (item.name));
                });

                action.invalid_uri.connect ((item) => {
                    item.status = Models.RequestStatus.SENT;
                    content.update_status (item);
                    content.set_error ("Invalid URI: %s".printf (item.name));
                });

                action.proxy_failed.connect ((item) => {
                    item.status = Models.RequestStatus.SENT;
                    content.update_status (item);
                    content.set_error ("Proxy denied request: %s".printf (item.name));
                });

                action.aborted.connect (() => {
                    item.status = Models.RequestStatus.SENT;
                    content.update_status (item);
                });

                action.make_request.begin ();
            });

            content.header_added.connect((header) =>  {
                var item = sidebar.get_active_item ();
                item.add_header (header);
            });

            content.cancel_process.connect (() => {
                if (action != null) {
                    action.cancel ();
                    var item = action.get_item ();
                    item.status = Models.RequestStatus.SENT;
                    if (item == sidebar.get_active_item ()) {
                        content.update_status (item);
                    }
                }
            });

            content.header_deleted.connect ((header) => {
                var item = sidebar.get_active_item ();

                item.remove_header (header);
            });

            sidebar.item_deleted.connect ((item) => {
                items.remove (item);

                if (items.size == 0) {
                    content.show_welcome ();
                }
            });

            content.item_changed.connect ((item) => {
                sidebar.update_active (item);
            });
        }

        private void show_create_request_dialog () {
            var dialog = new Dialogs.Request.CreateDialog (main.window);
            dialog.show_all ();
            dialog.creation.connect ((item) => {
                add_item (item);
                update_headerbar (item);
                content.show_request (item);
            });
        }

        private void show_update_request_dialog (Models.Request item) {
           var dialog = new Dialogs.Request.UpdateDialog (main.window, item);
           dialog.show_all ();
           dialog.updated.connect ((item) => {
               update_headerbar (item);

               if (item == sidebar.get_active_item ()) {
                   update_content (item);
               }
           });
        }

        private void update_headerbar (Models.Request item) {
            headerbar.subtitle = item.name;
        }

        private void update_content (Models.Request item) {
            content.show_request (item);
        }

        public void add_item (Models.Request item) {
            items.add (item);
            sidebar.add_item (item);
        }

        public unowned Gee.ArrayList<Models.Request> get_items_reference () {
            return items;
        }
    }
}
