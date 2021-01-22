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

namespace Spectator.Widgets {
    class RequestResponsePane : Gtk.Paned, Request.Interface {
        private Request.Container request_view;
        private Response.Container current_response_view;
        private weak Spectator.Window window;
        private uint active_id;
        private SendingService sending_service;
        private Gee.HashMap<uint, Response.Container> response_views;

        public signal void type_changed (RequestBody.ContentType type);
        public signal void reset_body (RequestBody.ContentType type);
        public signal void content_changed (string content);
        public signal void script_changed (string script);
        public signal void key_value_added (Pair item);
        public signal void key_value_removed (Pair item);
        public signal void key_value_updated (Pair item);
        public signal void request_edit_clicked (uint id);
        public signal void send_error (string error);
        public signal void clear_error ();
        public signal void request_sent (uint id);

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
                this.request_view.set_script_buffer (request.id);
                this.request_view.set_headers (request.headers);
                this.request_view.set_body (request.request_body);

                if (this.response_views.has_key (id)) {
                    var res_view = response_views[id];
                    remove (current_response_view);
                    this.current_response_view = res_view;
                    pack2 (current_response_view, false, false);
                    this.request_view.set_request_status (Models.RequestStatus.SENT);
                    this.current_response_view.show ();
                } else {
                    this.request_view.set_request_status (Models.RequestStatus.NOT_SENT);
                    this.current_response_view.hide ();
                }
            }
        }

        public RequestResponsePane (Spectator.Window window) {
            this.window = window;
            this.request_view = new Request.Container (window);
            this.current_response_view = new Response.Container ();
            this.sending_service = new SendingService ();
            response_views = new Gee.HashMap<uint, Response.Container> ();

            this.sending_service.request_script_output.connect ((id, str, type) => {
                this.request_view.update_buffer (id, str, type);
            });

            this.sending_service.finished_request.connect ((request, res) => {
                this.request_view.set_request_status (Models.RequestStatus.SENT);
                Response.Container res_view;

                // Use response view from cache if available
                if (response_views.has_key (request.id)) {
                    res_view = response_views[request.id];
                } else {
                    res_view = new Response.Container ();
                    response_views[request.id] = res_view;
                }

                remove (current_response_view);
                current_response_view = res_view;
                request_sent (request.id);
                pack2 (current_response_view, false, false);
                current_response_view.show_all ();
                res_view.update (res);
            });

            request_view.url_params_updated.connect ((query_pairs) => {
                var request = this.window.request_service.get_request_by_id (active_id);

                if (request != null) {
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

                    request.query = query_builder.str;
                    this.request_view.set_url_entry (request.uri);
                    this.url_changed (request.uri);
                }
            });

            request_view.url_changed.connect ((url) => {
                this.url_changed (url);
            });

            request_view.cancel_process.connect (() => {
                this.sending_service.cancel (active_id);
            });

            request_view.content_changed.connect ((content) => {
                var request = this.window.request_service.get_request_by_id (active_id);

                if (request != null) {
                    this.content_changed (content);
                }
            });

            request_view.request_activated.connect (() => {
                var req = this.window.request_service.get_request_by_id (this.active_id);
                var result  = window.variable_resolver.resolve_variables (req.uri);

                if (!result.has_errors ()) {
                    req.uri = result.resolved_text;
                } else {
                    if (result.unresolved_variable_names.size == 1) {
                        this.send_error ("%s is not defined".printf (result.unresolved_variable_names.get (0)));
                    } else {
                        var builder = new StringBuilder ();
                        var first = true;
                        
                        foreach (var variable in result.unresolved_variable_names) {
                            if (first) {
                                first = false;
                                builder.append (variable);
                            } else {
                                builder.append (", %s".printf (variable));
                            }
                        }

                        builder.append (" are not defined");

                        this.send_error (builder.str);
                    }
                    return;
                }

                if (Services.Utilities.valid_uri_string (req.uri)) {
                    this.request_view.set_request_status (Models.RequestStatus.SENDING);
                    this.sending_service.send_request.begin (req);
                    this.clear_error ();
                } else {
                    this.send_error ("Invalid URI");
                }
            });

            request_view.method_changed.connect ((method) => {
                this.method_changed (method);
            });

            request_view.header_added.connect ((headers) => {
                this.window.request_service.update_request (active_id, (updater) => {
                    updater.update_headers (headers);
                });
            });

            request_view.script_changed.connect ((script) => {
                this.window.request_service.update_request (active_id, (updater) => {
                    updater.update_script (script);
                });
            });

            request_view.header_deleted.connect ((headers) => {
                this.window.request_service.update_request (active_id, (updater) => {
                    updater.update_headers (headers);
                });
            });

            request_view.body_type_changed.connect ((type) => {
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
                            this.reset_body (type);
                        }

                        message_dialog.destroy ();
                    } else {
                        request.request_body.type = type;
                        this.type_changed (type);
                    }
                }
                request_view.set_request_body (request.request_body);
            });

            pack1 (request_view, false, false);
            pack2 (current_response_view, false, false);
        }

        public void update_status (Models.Request request) {
            request_view.update_status (request);
        }

        construct {
            orientation = Gtk.Orientation.HORIZONTAL;
        }
    }
}
