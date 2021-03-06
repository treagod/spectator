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

namespace Spectator.Widgets.Sidebar {
    public enum DnDTarget {
        REQUEST,
        COLLECTION
    }
    public const Gtk.TargetEntry[] TARGET_ENTRIES_LABEL = {
        { "REQUEST", Gtk.TargetFlags.SAME_APP, DnDTarget.REQUEST },
        { "COLLECTION", Gtk.TargetFlags.SAME_APP, DnDTarget.COLLECTION },
    };

    public class TitleBar : Gtk.Box {
        private Gtk.Label title;
        private weak Repository.IEnvironment environments;
        private Gtk.Box environment_box;
        public bool source_destination;

        public signal void request_dropped (uint id);
        public signal void request_dragged ();
        public signal void request_removed ();
        public signal void environment_changed ();

        public string title_text {
            get {
                return title.label;
            }
            set {
                title.label = value;
            }
        }

        public TitleBar (Repository.IEnvironment envs) {
            environments = envs;
            orientation = Gtk.Orientation.VERTICAL;
            source_destination = true;

            title = new Gtk.Label (envs.get_current_environment ().name);
            title.get_style_context ().add_class ("h3");
            title.halign = Gtk.Align.START;
            title.margin = 5;
            var down_arrow = new Gtk.Image.from_icon_name ("pan-down-symbolic", Gtk.IconSize.MENU);
            var box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
            var event_box = new Gtk.EventBox ();
            box.add(title);
            box.add (down_arrow);
            box.hexpand = true;
            box.halign = Gtk.Align.START;
            var popover = new Gtk.Popover (this);

            environment_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 2);

            popover.add (environment_box);

            popover.closed.connect (() => {
                environment_box.foreach ((w) => {
                    environment_box.remove (w);
                });
            });

            event_box.add (box);
            event_box.button_release_event.connect (() => {
                show_environments ();
                popover.popup ();
                return true;
            });

            pack_start (event_box, true, true, 0);
            this.build_drag_and_drop ();
        }

        private void build_drag_and_drop () {
            Gtk.drag_dest_set (this, Gtk.DestDefaults.ALL, TARGET_ENTRIES_LABEL, Gdk.DragAction.MOVE);
            this.drag_data_received.connect (on_drag_data_received);
            this.drag_motion.connect (on_drag_motion);
            this.drag_leave.connect (on_drag_leave);
        }

        private void on_drag_data_received (Gdk.DragContext context, int x, int y,
            Gtk.SelectionData selection_data, uint target_type, uint time) {
            /* Drag & Drop is only activated for collection mode */
            if (source_destination) {
                var row = ((Gtk.Widget[]) selection_data.get_data ())[0];
                var source = (RequestListItem) row;

                this.request_dropped (source.id);
            }
        }

        public bool on_drag_motion (Gdk.DragContext context, int x, int y, uint time) {
            request_dragged ();

            return true;
        }

        public void on_drag_leave (Gdk.DragContext context, uint time) {
            request_removed ();
        }

        public void show_environments () {
            foreach (var env in environments.get_environments ()) {
                var button = new Gtk.ModelButton ();

                button.label = env.name;
                button.clicked.connect (() => {
                    title.label = env.name;
                    environments.set_current_environment (env);
                    environment_changed ();
                });
                environment_box.add(button);
                environment_box.show_all ();
            }
            title.label = environments.get_current_environment ().name;
        }
    }

    public class Container : Gtk.Box {
        private Gtk.ScrolledWindow collection_scroll;
        private Gtk.ScrolledWindow history_scroll;
        private Gtk.Stack stack;
        public Collection.Container collection;
        public History.Container history;
        private TitleBar titlebar;
        private weak Spectator.Window window;
        private Granite.Widgets.ModeButton mode_buttons;

        public signal void selection_changed (Models.Request item); /* Deprecated */
        public signal void request_item_selected (uint id);
        public signal void request_edit_clicked (uint id);
        public signal void request_delete_clicked (uint id);
        public signal void collection_request_delete_clicked (uint id);
        public signal void notify_delete ();
        public signal void create_collection_request (uint id);
        public signal void collection_edit (uint id);

        public Container (Spectator.Window window) {
            this.window = window;
            history_scroll = new Gtk.ScrolledWindow (null, null);
            history_scroll.hscrollbar_policy = Gtk.PolicyType.AUTOMATIC;
            history_scroll.vscrollbar_policy = Gtk.PolicyType.AUTOMATIC;

            collection_scroll = new Gtk.ScrolledWindow (null, null);
            collection_scroll.hscrollbar_policy = Gtk.PolicyType.AUTOMATIC;
            collection_scroll.vscrollbar_policy = Gtk.PolicyType.AUTOMATIC;
            titlebar = new TitleBar (window.environment_service);

            orientation = Gtk.Orientation.VERTICAL;
            width_request = 265;

            collection = new Collection.Container (window);
            history = new History.Container (window);

            collection_scroll.add (collection);
            history_scroll.add (history);

            collection.create_collection_request.connect ((collection_id) => {
                create_collection_request (collection_id);
            });

            collection.collection_edit.connect ((id) => {
                collection_edit (id);
            });

            collection.collection_delete.connect ((id, contains_active_request) => {
                var collection = this.window.collection_service.get_collection_by_id (id);

                if (collection != null) {
                    var message_dialog = new Granite.MessageDialog.with_image_from_icon_name (
                        _("Delete Collection?"),
                        _("""This action will permanently delete <b>%s</b>.
All requests for this collection will also be deleted.
This can't be undone!""".printf (collection.name)),
                        "dialog-warning",
                        Gtk.ButtonsType.CANCEL
                   );
                   message_dialog.transient_for = this.window;

                   message_dialog.secondary_label.use_markup = true;

                   var suggested_button = new Gtk.Button.with_label (_("Delete Collection"));
                   suggested_button.get_style_context ().add_class (Gtk.STYLE_CLASS_DESTRUCTIVE_ACTION);
                   message_dialog.add_action_widget (suggested_button, Gtk.ResponseType.ACCEPT);

                   message_dialog.show_all ();
                   if (message_dialog.run () == Gtk.ResponseType.ACCEPT) {
                       this.window.collection_service.delete_collection (collection.id);
                       this.show_items ();

                       if (contains_active_request) {
                           this.window.show_welcome ();
                           this.collection.unselect ();
                       }
                   }

                   message_dialog.destroy ();
                }
            });

            collection.request_item_selected.connect ((id) => {
                this.request_item_selected (id);
                this.history.select_request (id);
            });

            collection.request_edit_clicked.connect ((id) => {
                this.request_edit_clicked (id);
            });

            collection.request_clone_clicked.connect ((id) => {
                var request = this.window.request_service.get_request_by_id (id);

                if (request != null) {
                    var new_request = new Models.Request.clone (request);
                    this.window.request_service.add_request (new_request);
                    this.window.request_service.update_request(new_request.id, (updater) => {
                        updater.update_body_type (new_request.request_body.type);
                        updater.update_body_content (new_request.request_body.content);
                    });

                    if (new_request.collection_id != null) {
                        this.window.collection_service.add_request_to_collection (
                            new_request.collection_id,
                            new_request.id
                        );
                    }

                    this.window.order_service.move_request_after_request (
                        request.id,
                        new_request.id
                    );
                    this.show_items ();
                }
            });

            collection.request_delete_clicked.connect ((id) => {
                this.request_delete_clicked (id);
                this.collection.unselect ();
            });

            collection.collection_request_delete_clicked.connect ((req_id) => {
                this.collection_request_delete_clicked (req_id);
            });

            collection.request_moved.connect ((target_id, moved_id) => {
                var target_request = this.window.request_service.get_request_by_id (target_id);
                this.clear_request_collection (moved_id);

                if (target_request != null) {
                    this.window.order_service.move_request_after_request (target_id, moved_id);
                }

                this.show_items ();
            });

            collection.request_moved_after_collection_request.connect ((target_id, moved_id, collection_id) => {
                this.clear_request_collection (moved_id);

                this.window.order_service.append_after_request_to_collection_requests (
                    collection_id,
                    target_id,
                    moved_id
                );

                this.show_items ();
            });

            collection.request_added_to_collection.connect ((collection_id, id) => {
                this.clear_request_collection (id);
                this.window.order_service.add_request_to_collection_begin (collection_id, id);
                this.show_items ();
            });

            collection.request_moved_to_end.connect ((id) => {
                this.clear_request_collection (id);
                this.window.order_service.move_request_to_end (id);
                this.show_items ();
            });

            titlebar.request_dropped.connect ((id) => {
                this.clear_request_collection (id);
                this.window.order_service.move_request_to_begin (id);
                this.show_items ();
            });

            titlebar.environment_changed.connect (() => {
                this.show_items ();
            });

            titlebar.request_dragged.connect (() => {
                collection.drag_reavel_top ();
            });

            titlebar.request_removed.connect (() => {
                collection.drag_hide_top ();
            });

            history.request_item_selected.connect ((id) => {
                this.request_item_selected (id);
                this.collection.select_request (id);
            });

            history.request_edit_clicked.connect ((id) => {
                this.request_edit_clicked (id);
            });

            history.request_delete_clicked.connect ((id) => {
                this.request_delete_clicked (id);
            });

            stack = new Gtk.Stack ();
            stack.add_named (collection_scroll, "groups");
            stack.add_named (history_scroll, "history");

            stack.set_visible_child (collection_scroll);

            mode_buttons = create_mode_buttons ();

            mode_buttons.mode_changed.connect (() => {
                if (mode_buttons.selected == 0) {
                    stack.set_visible_child (collection_scroll);
                    titlebar.source_destination = true;
                } else {
                    stack.set_visible_child (history_scroll);
                    titlebar.source_destination = false;
                }
            });

            this.titlebar.hexpand = true;
            this.titlebar.halign = Gtk.Align.CENTER;

            var separator = new Gtk.Separator (Gtk.Orientation.HORIZONTAL);
            separator.margin_top = 2;

            mode_buttons.get_style_context ().add_class ("square");

            this.pack_start (this.titlebar, false, true, 0);
            this.pack_start (separator, false, true, 0);
            this.pack_start (this.stack, true, true, 0);
            this.pack_end (this.mode_buttons, false, true, 0);
        }

        private void clear_request_collection (uint request_id) {
            var moved_request = this.window.request_service.get_request_by_id (request_id);

            if (moved_request != null) {
                if (moved_request.collection_id != null) {
                    var collection = this.window.collection_service.get_collection_by_id (moved_request.collection_id);
                    if (collection != null) {
                        collection.remove_request (request_id);
                    }

                    moved_request.collection_id = null;
                }
            }
        }

        public void show_history () {
            mode_buttons.selected = 1;
            stack.set_visible_child (history_scroll);
            titlebar.source_destination = false;
        }

        public void show_collection () {
            mode_buttons.selected = 0;
            stack.set_visible_child (collection_scroll);
            titlebar.source_destination = true;
        }

        public void add_collection (Models.Collection model) {
            collection.add_collection (model);
        }

        public void select_request (uint id) {
            collection.select_request (id);
        }

        public void show_items () {
            this.show_collection_items ();
            this.show_history_items ();
        }

        public void show_collection_items () {
            this.collection.show_items ();
        }

        public void show_history_items () {
            this.history.show_items ();
        }

        private Granite.Widgets.ModeButton create_mode_buttons () {
            var mode = new Granite.Widgets.ModeButton ();
            mode.append_icon ("view-list-symbolic", Gtk.IconSize.SMALL_TOOLBAR);
            mode.append_icon ("document-open-recent-symbolic", Gtk.IconSize.SMALL_TOOLBAR);
            mode.set_active (0);

            return mode;
        }

        public void update_active_method (Models.Method method) {
            collection.update_active_method (method);
            //history.update_active_url ();
        }

        public void update_active_url (string url) {
            collection.update_active_url (url);
            //history.update_active_url ();
        }
    }
}