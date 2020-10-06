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

namespace Spectator {
    public class Window : Gtk.ApplicationWindow {
        public signal void close_window ();

        private Widgets.HeaderBar headerbar;
        private Widgets.Sidebar.Container sidebar;
        private Widgets.Content content;

        private Repository.IRequest _request_service;
        public Repository.IRequest request_service {
            get {
                return this._request_service;
            }
            private set {
                this._request_service = value;
            }
        }

        private Repository.ICollection _collection_service;
        public Repository.ICollection collection_service {
            get {
                return this._collection_service;
            }
            private set {
                this._collection_service = value;
            }
        }

        private Repository.ICustomOrder _order_service;
        public Repository.ICustomOrder order_service {
            get {
                return this._order_service;
            }
            private set {
                this._order_service = value;
            }
        }

        public Window (Gtk.Application app, Repository.IRequest request_service,
                       Repository.ICollection collection_service, Repository.ICustomOrder order_service) {
            var settings = Settings.get_instance ();
            Object (application: app);

            Gtk.Settings.get_default ().gtk_application_prefer_dark_theme = settings.dark_theme;
            move (settings.pos_x, settings.pos_y);
            resize (settings.window_width, settings.window_height);

            if (settings.maximized) {
                maximize ();
            }

            this.request_service = request_service;
            this.collection_service = collection_service;
            this.order_service = order_service;
            this.sidebar.show_items ();
        }

        construct {
            var provider = new Gtk.CssProvider ();
            provider.load_from_resource ("/com/github/treagod/spectator/stylesheet.css");
            Gtk.StyleContext.add_provider_for_screen (Gdk.Screen.get_default (),
                                                      provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

            this.headerbar = new Widgets.HeaderBar ();
            this.setup_headerbar_events ();
            this.set_titlebar (this.headerbar);
            this.create_paned ();
        }

        private void setup_headerbar_events () {
            this.headerbar.new_request.clicked.connect (() => {
                this.create_request_dialog ();
            });

            this.headerbar.preference_clicked.connect (() => {
                open_preferences ();
            });

            this.headerbar.new_collection.clicked.connect (() => {
                this.create_collection_dialog ();
            });
        }

        private void open_preferences () {
            var dialog = new Dialogs.Preferences (this);

            dialog.show_all ();
        }

        private void display_request (Models.Request request) {
            this.headerbar.subtitle = request.name;
            this.content.display_request (request.id);
        }

        public void create_request_dialog () {
            var dialog = new Dialogs.Request.CreateDialogNew (this);
            dialog.creation.connect ((request) => {
                request.script_code = "// function before_sending(request) {\n// }"; // Init script

                /*
                    If request was successfully created, refresh sidebar content, select the newly
                   created request entry and display its content
                */
                if (this.request_service.add_request (request)) {
                    this.sidebar.show_collection_items ();
                    this.sidebar.select_request (request.id);
                    this.display_request (request);
                }
            });
            dialog.show_all ();
        }

        public void create_collection_dialog () {
            var dialog = new Dialogs.Collection.CollectionDialog (this);
            dialog.creation.connect ((collection) => {
                if (this.collection_service.add_collection (collection)) {
                    this.sidebar.show_collection_items ();
                }
            });
            dialog.show_all ();
        }

        private void create_paned () {
            var paned = new Gtk.Paned (Gtk.Orientation.HORIZONTAL);
            paned.wide_handle = true;

            this.content = new Widgets.Content (this);
            this.content.hexpand = true;

            this.setup_content_events ();

            this.sidebar = new Widgets.Sidebar.Container (this);
            sidebar.hexpand = false;

            this.setup_sidebar_events ();

            paned.pack1 (sidebar, false, false);
            paned.pack2 (content, true, false);

            this.add (paned);
        }

        private void setup_content_events () {
            this.content.url_changed.connect ((id, url) => {
                this.sidebar.update_active_url (url);
                this.request_service.update_request (id, (updater) => {
                    updater.update_url (url);
                });
            });

            this.content.request_sent.connect ((id) => {
                this.request_service.update_request (id, (updater) => {
                    updater.update_last_sent(new DateTime.now_local ());
                });
                this.sidebar.show_history_items ();
            });

            this.content.method_changed.connect ((id, method) => {
                this.sidebar.update_active_method (method);
                this.request_service.update_request (id, (updater) => {
                    updater.update_method (method);
                });
             });

            this.content.body_type_changed.connect ((id, body_type) => {
                this.request_service.update_request (id, (updater) => {
                    updater.update_body_type (body_type);
                });
             });

             this.content.body_reset.connect ((id, body_type) => {
                this.request_service.update_request (id, (updater) => {
                    updater.update_body_type (body_type);
                    updater.update_body_content ("");
                });
             });

             this.content.body_content_changed.connect ((id, body_content) => {
                this.request_service.update_request (id, (updater) => {
                    updater.update_body_content (body_content);
                });
             });
        }

        public void show_welcome () {
            this.content.show_welcome ();
        }

        private void setup_sidebar_events () {
            /* Adds visual look to selected item, clearing previous selected item (if any) */
            this.sidebar.request_item_selected.connect ((id) => {
                var request = this.request_service.get_request_by_id (id);

                if (request != null) {
                    this.display_request (request);
                } else {
                    error ("Not able to find request with id %u\n", id);
                }
            });

            this.sidebar.collection_request_delete_clicked.connect ((req_id) => {
                var request = this.request_service.get_request_by_id (req_id);
                if (request != null) {
                    var message_dialog = new Granite.MessageDialog.with_image_from_icon_name (
                        _("Delete Request?"),
                        _("This action will permanently delete <b>%s</b>. This can't be undone!".printf (request.name)),
                        "dialog-warning",
                        Gtk.ButtonsType.CANCEL
                   );

                   message_dialog.transient_for = this;
                   message_dialog.secondary_label.use_markup = true;

                   var suggested_button = new Gtk.Button.with_label (_("Delete Request"));
                   suggested_button.get_style_context ().add_class (Gtk.STYLE_CLASS_DESTRUCTIVE_ACTION);
                   message_dialog.add_action_widget (suggested_button, Gtk.ResponseType.ACCEPT);

                   message_dialog.show_all ();
                   if (message_dialog.run () == Gtk.ResponseType.ACCEPT) {
                    this.request_service.delete_request (req_id);
                    this.sidebar.show_items ();
                    this.content.show_welcome ();
                   }

                   message_dialog.destroy ();
                }
            });

            this.sidebar.request_edit_clicked.connect ((id) => {
                var request = this.request_service.get_request_by_id (id);

                if (request != null) {
                    var dialog = new Dialogs.Request.UpdateDialog (this, request);

                    dialog.updated.connect ((name, method) => {
                        this.request_service.update_request (id, (updater) => {
                            updater.update_name (name);
                            updater.update_method (method);
                        });
                        this.sidebar.show_items ();
                        this.sidebar.select_request (request.id);
                        this.display_request (request);
                    });

                    dialog.show_all ();
                }
            });

            this.sidebar.request_delete_clicked.connect ((id) => {
                var request = this.request_service.get_request_by_id (id);

                if (request != null) {
                    var message_dialog = new Granite.MessageDialog.with_image_from_icon_name (
                        _("Delete Request?"),
                        _("This action will permanently delete <b>%s</b>. This can't be undone!".printf (request.name)),
                        "dialog-warning",
                        Gtk.ButtonsType.CANCEL
                   );

                   message_dialog.transient_for = this;
                   message_dialog.secondary_label.use_markup = true;

                   var suggested_button = new Gtk.Button.with_label (_("Delete Request"));
                   suggested_button.get_style_context ().add_class (Gtk.STYLE_CLASS_DESTRUCTIVE_ACTION);
                   message_dialog.add_action_widget (suggested_button, Gtk.ResponseType.ACCEPT);

                   message_dialog.show_all ();
                   if (message_dialog.run () == Gtk.ResponseType.ACCEPT) {
                    this.request_service.delete_request (id);
                    this.sidebar.show_items ();
                    this.content.show_welcome ();
                   }

                   message_dialog.destroy ();
                }
            });

            this.sidebar.create_collection_request.connect ((id) => {
                var collection = this.collection_service.get_collection_by_id (id);

                if (collection != null) {
                    var dialog = new Dialogs.Request.CreateDialogWithCollection (this, collection);

                    dialog.creation.connect ((request) => {
                        this.request_service.add_request (request);
                        this.collection_service.add_request_to_collection (id, request.id);
                        this.sidebar.show_collection_items ();
                    });

                    dialog.show_all ();
                }
            });

            this.sidebar.collection_edit.connect ((id) => {
                var collection = this.collection_service.get_collection_by_id (id);

                if (collection != null) {
                    var dialog = new Dialogs.Collection.UpdateCollectionDialog (this, collection);

                    dialog.updated.connect ((name) => {
                        this.collection_service.rename (id, name);
                        this.sidebar.show_items ();
                    });

                    dialog.show_all ();
                }
            });
        }

        protected override bool delete_event (Gdk.EventAny event) {
            var settings = Settings.get_instance ();
            int width, height, x, y;

            get_size (out width, out height);
            get_position (out x, out y);

            settings.pos_x = x;
            settings.pos_y = y;
            settings.window_width = width;
            settings.window_height = height;
            settings.maximized = is_maximized;

            close_window ();

            return false;
        }
    }
}
