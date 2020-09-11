/*
* Copyright (c) 2020 Marvin Ahlgrimm (https://github.com/treagod)
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
        private Models.Request last_item;
        private Spectator.Window window;
        private uint active_id;

        public signal void type_changed (RequestBody.ContentType type);
        public signal void script_changed (string script);
        public signal void key_value_added (Pair item);
        public signal void key_value_removed (Pair item);
        public signal void key_value_updated (Pair item);
        public signal void request_edit_clicked (uint id);

        public void display_request (uint id) {
            this.active_id = id;
            this.refresh_request (id);
        }

        private void refresh_request (uint id) {
            var request = this.window.request_service.get_request_by_id (id);

            if (request != null) {
                this.request_view.set_request_url (request.uri);
                this.request_view.set_request_method (request.method);
                this.request_view.set_script (request.script_code);
                this.request_view.set_headers (request.headers);
                this.request_view.set_body (request.request_body);

                if (request.response != null) {
                    //
                } else {}
            }
        }

        public RequestResponsePane (Spectator.Window window) {
            this.window = window;
            this.request_view = new Request.Container ();
            this.response_view = new Response.Container ();
            this.response_view = new Response.Container ();
            this.tab_indecies = new Gee.HashMap<Models.Request, int> ();

            request_view.response_received.connect ((res) => {
                response_view.update (res);
            });

            request_view.url_params_updated.connect ((query_pairs) => {
                var request = this.window.request_service.get_request_by_id (active_id);

                if (request != null) {
                    this.url_changed (request.uri);
                    var query_builder = new StringBuilder ();
                    var first = true;

                    foreach (var pair in query_pairs) {
                        if (first) {
                            first = false;
                        } else {
                            if (pair.key.strip ().length > 0) {
                                query_builder.append ("&");
                            }
                        }
                        if (pair.key.strip ().length > 0) {
                            query_builder.append ("%s=%s".printf (pair.key, pair.val));
                        }
                    }

                    var query_string = query_builder.str;

                    if (query_string.length > 0) {
                        request.query = query_builder.str;
                        this.request_view.set_url_entry (request.uri);
                    }
                }
            });

            request_view.url_changed.connect ((url) => {
                var request = this.window.request_service.get_request_by_id (active_id);

                if (request != null) {
                    request.uri = url; // TODO: This allready saves the request, which should be explicit
                    url_changed (url);
                }
            });

            request_view.cancel_process.connect (() => {
                cancel_process ();
            });

            request_view.content_changed.connect ((content) => {
                var request = this.window.request_service.get_request_by_id (active_id);

                if (request != null) {
                    request.request_body.content = content; // TODO: This allready saves the request, which should be explicit
                }
            });

            request_view.request_activated.connect (() => {
                request_activated ();
            });

            request_view.method_changed.connect ((method) => {
                var request = this.window.request_service.get_request_by_id (active_id);

                if (request != null) {
                    request.method = method; // TODO: This allready saves the request, which should be explicit
                    method_changed (method);
                }
            });

            request_view.header_added.connect ((header) => {
                var request = this.window.request_service.get_request_by_id (active_id);

                if (request != null) {
                    request.add_header(header);
                }
            });

            request_view.script_changed.connect ((script) => {
                var request = this.window.request_service.get_request_by_id (active_id);

                if (request != null) {
                    request.script_code = script;
                }
            });

            request_view.header_deleted.connect ((header) => {
                header_added (header);
                var request = this.window.request_service.get_request_by_id (active_id);

                if (request != null) {
                    request.remove_header (header);
                }
            });

            request_view.type_changed.connect ((type) => {
                var request = this.window.request_service.get_request_by_id (active_id);

                if (request != null) {
                    if (type != request.request_body.type && request.request_body.content.length > 0) {
                        var message_dialog = new Granite.MessageDialog.with_image_from_icon_name (
                             _("Are you sure you want to change the type?"),
                             _("This action will delete the current body content. Proceed changing the body type?"),
                             "dialog-warning",
                             Gtk.ButtonsType.CANCEL
                        );
                        message_dialog.transient_for = this.window;

                        var suggested_button = new Gtk.Button.with_label (_("Change Type"));
                        suggested_button.get_style_context ().add_class (Gtk.STYLE_CLASS_DESTRUCTIVE_ACTION);
                        message_dialog.add_action_widget (suggested_button, Gtk.ResponseType.ACCEPT);

                        message_dialog.show_all ();
                        if (message_dialog.run () == Gtk.ResponseType.ACCEPT) {
                            request.request_body.content = "";
                            request.request_body.type = type;
                            request_view.reset_body ();
                        }

                        message_dialog.destroy ();
                    } else {
                        request.request_body.type = type;
                    }
                }
                request_view.set_request_body (request.request_body);
            });

            pack1 (request_view, true, false);
            pack2 (response_view, true, false);
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

        public void update_response (Models.Request request) {
            if (request.response != null) {
                response_view.update_test (request);
                response_view.show_all ();

                if (get_child2 () == null) {
                    pack2 (response_view, true, false);
                }
            } else {
                if (get_child2 () != null) {
                    remove (response_view);
                }
            }

            show_all ();
        }

        public void update_chunk_response (Models.Request item) {
            // TODO: Handle in view itself
            item.response.add_header ("Content-Type", "text/plain");
            update_response (item);
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
