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

uint? active_id = null;

namespace Spectator.Services {
    public class WindowBuilder {
        private Window window;
        private Repository.IRequest request_repository;
        private Repository.ICollection collection_repository;
        private Repository.ICustomOrder order_repository;
        private Repository.IEnvironment environment_repository;
        public WindowBuilder (Repository.IRequest rr,
            Repository.ICollection cr,
            Repository.ICustomOrder or,
            Repository.IEnvironment er) {
            request_repository = rr;
            collection_repository = cr;
            order_repository = or;
            environment_repository = er;
        }
        
        private Widgets.Request.Container build_request_box () {
            var box = new Widgets.Request.Container (request_repository, environment_repository);

            box.url_params_updated.connect ((query_pairs) => {
                var request = request_repository.get_request_by_id (active_id);

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
                    box.set_url_entry (request.uri);
                    this.window.sidebar.update_active_url (request.uri);
                    request_repository.update_request (active_id, (updater) => {
                        updater.update_url (request.uri);
                    });
                }
            });

            box.method_changed.connect ((id, method) => {
                window.sidebar.update_active_method (method);
                request_repository.update_request (active_id, (updater) => {
                    updater.update_method (method);
                });
             });

             box.header_added.connect ((headers) => {
                request_repository.update_request (active_id, (updater) => {
                    updater.update_headers (headers);
                });
            });

            box.header_deleted.connect ((headers) => {
                request_repository.update_request (active_id, (updater) => {
                    updater.update_headers (headers);
                });
            });

            box.body_type_changed.connect ((type) => {
                var request = request_repository.get_request_by_id (active_id);

                if (request != null) {
                    if (type != request.request_body.type && request.request_body.content.length > 0) {
                        var message_dialog = new Granite.MessageDialog.with_image_from_icon_name (
                             _("Are you sure you want to change the type?"),
                             _("This action will delete the current body content. Proceed changing the body type?"),
                             "dialog-warning",
                             Gtk.ButtonsType.CANCEL
                        );

                        var suggested_button = new Gtk.Button.with_label (_("Change Type"));
                        suggested_button.get_style_context ().add_class (Gtk.STYLE_CLASS_DESTRUCTIVE_ACTION);
                        message_dialog.add_action_widget (suggested_button, Gtk.ResponseType.ACCEPT);

                        message_dialog.show_all ();
                        if (message_dialog.run () == Gtk.ResponseType.ACCEPT) {
                            request.request_body.content = "";
                            request.request_body.type = type;
                            box.reset_body ();
                            request_repository.update_request (active_id, (updater) => {
                                updater.update_body_type (type);
                                updater.update_body_content ("");
                            });
                        }

                        message_dialog.destroy ();
                    } else {
                        request.request_body.type = type;
                        request_repository.update_request (active_id, (updater) => {
                            updater.update_body_type (type);
                        });
                    }
                }
                box.set_request_body (request.request_body);
            });

            return box;
        }

        public Window build_window (Gtk.Application app) {
            var req_container = build_request_box ();
            
            var req_res = new Widgets.RequestResponsePane (request_repository, environment_repository, req_container);
            
            window = new Window (
                app,
                request_repository,
                collection_repository,
                order_repository,
                environment_repository,
                new Widgets.Content (request_repository, environment_repository, req_res)
            );

            window.sidebar.selection_changed.connect ((request) => {
                active_id = request.id;
            });
            return window;
        }
    }
}