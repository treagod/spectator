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

namespace Spectator.Services {
    public class RequestController {
        private Models.Request? active_request;
        private Widgets.Request.Container request_view;
        private Widgets.Sidebar.Container sidebar_view;
        private Repository.IRequest repository;

        public RequestController (Widgets.Request.Container req_view, Widgets.Sidebar.Container side_view, Repository.IRequest reqs) {
            active_request = null;
            request_view = req_view;
            sidebar_view = side_view;
            repository = reqs;

            setup_signals ();
        }

        private void display_request (Models.Request request) {
            this.request_view.set_request_url (request.uri);
            this.request_view.set_request_method (request.method);
            this.request_view.set_script (request.script_code);
            this.request_view.set_script_buffer (request.id);
            this.request_view.set_headers (request.headers);
            this.request_view.set_body (request.request_body);
        }

        private void setup_signals () {
            sidebar_view.request_item_selected.connect ((id) => {
                print("%u\n", id);
                var request = repository.get_request_by_id (id);

                if (request != null) {
                    print ("asdasdasdlollol\n");
                }

                //  if (request != null) {
                //      this.display_request (request);
                //  } else {
                //      error ("Not able to find request with id %u\n", id);
                //  }
            });

            request_view.url_params_updated.connect ((query_pairs) => {
                var request = repository.get_request_by_id (active_request.id);

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
                    request_view.set_url_entry (request.uri);
                    sidebar_view.update_active_url (request.uri);
                    repository.update_request (active_request.id, (updater) => {
                        updater.update_url (request.uri);
                    });
                }
            });

            request_view.method_changed.connect ((id, method) => {
                sidebar_view.update_active_method (method);
                repository.update_request (active_request.id, (updater) => {
                    updater.update_method (method);
                });
             });

             request_view.header_added.connect ((headers) => {
                repository.update_request (active_request.id, (updater) => {
                    updater.update_headers (headers);
                });
            });

            request_view.header_deleted.connect ((headers) => {
                repository.update_request (active_request.id, (updater) => {
                    updater.update_headers (headers);
                });
            });

            request_view.body_type_changed.connect ((type) => {
                var request = repository.get_request_by_id (active_request.id);

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
                            request_view.reset_body ();
                            repository.update_request (active_request.id, (updater) => {
                                updater.update_body_type (type);
                                updater.update_body_content ("");
                            });
                        }

                        message_dialog.destroy ();
                    } else {
                        request.request_body.type = type;
                        repository.update_request (active_request.id, (updater) => {
                            updater.update_body_type (type);
                        });
                    }
                }
                request_view.set_request_body (request.request_body);
            });
        }
    }
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

            var c = new RequestController (req_container, window.sidebar, request_repository);
            
            return window;
        }
    }
}