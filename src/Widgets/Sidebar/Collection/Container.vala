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

namespace Spectator.Widgets.Sidebar.Collection {
    public class Container : Gtk.Box {
        public signal void item_edit (Models.Request request);
        public signal void item_clone (Models.Request request);
        public signal void item_deleted (Models.Request request);
        public signal void request_item_selected (uint id);
        public signal void request_edit_clicked (uint id);
        public signal void request_clone_clicked (uint id);
        public signal void request_delete_clicked (uint id);
        public signal void create_collection_request (uint id);
        public signal void collection_edit (Models.Collection collection);
        public signal void collection_delete (uint id, bool contains_active_request);

        public signal void request_moved (uint target_id, uint moved_id);
        public signal void request_moved_to_end (uint moved_id);
        public signal void request_moved_after_collection_request (uint target_id, uint moved_id, uint collection_id);
        public signal void request_added_to_collection (uint collection_id, uint id);

        public uint? active_id { get; private set; }
        private Gee.HashMap<uint, RequestListItem> request_items;
        private Gee.HashMap<uint, bool> collection_visiblity;
        private Spectator.Window window;
        private Gtk.Revealer motion_revealer;

        construct {
            orientation = Gtk.Orientation.VERTICAL;
            spacing = 3;
        }

        public Container (Spectator.Window window) {
            this.window = window;
            this.active_id = null;
            this.request_items = new Gee.HashMap<uint, RequestListItem> ();
            this.collection_visiblity = new Gee.HashMap<uint, bool> ();
            get_style_context ().add_class ("collection-box");

            Settings.get_instance ().theme_changed.connect (() => {
                @foreach ((child) => {
                    if (child is Dropdown) {
                        var dropdown = (Dropdown) child;

                        dropdown.each_item ((item) => {
                            item.repaint ();
                        });
                    } else if (child is RequestListItem) {
                        var list_item = (RequestListItem) child;
                        list_item.repaint ();
                    }
                });
            });

            this.build_drag_and_drop ();
            var motion_grid = new Gtk.Grid ();
            motion_grid.margin = 6;
            motion_grid.get_style_context ().add_class ("grid-motion");
            motion_grid.height_request = 18;

            this.motion_revealer = new Gtk.Revealer ();
            this.motion_revealer.transition_type = Gtk.RevealerTransitionType.SLIDE_DOWN;
            this.motion_revealer.add (motion_grid);
        }

        public void drag_reavel_top () {
            this.motion_revealer.reveal_child = true;
        }

        public void drag_hide_top () {
            this.motion_revealer.reveal_child = false;
        }

        private void build_drag_and_drop () {
            Gtk.drag_dest_set (this, Gtk.DestDefaults.ALL, TARGET_ENTRIES_LABEL, Gdk.DragAction.MOVE);
            this.drag_data_received.connect (on_drag_data_received);
        }

        private void on_drag_data_received (Gdk.DragContext context, int x, int y,
            Gtk.SelectionData selection_data, uint target_type, uint time) {
                var row = ((Gtk.Widget[]) selection_data.get_data ())[0];
                var source = (RequestListItem) row;

                this.request_moved_to_end (source.id);
        }

        /* Deprecated? */
        public void update_active_method (Models.Method method) {
            var active_item = this.request_items[active_id];

            if (active_item != null) {
                active_item.set_method (method);
            }
        }

        /* Deprecated? */
        public void update_active_url (string url) {
            var active_item = this.request_items[active_id];

            if (active_item != null) {
                active_item.set_url (url);
            }
        }

        /* Adds active css-class to selected item */
        public void select_request (uint id) {
            if (this.request_items.has_key (id)) {
                if (this.active_id != null) {
                    this.request_items[this.active_id].get_style_context ().remove_class ("active");
                }

                var request_item = this.request_items[id];
                request_item.get_style_context ().add_class ("active");
                this.active_id = id;
            } else {
                error ("No such id %u\n", id);
            }
        }

        public void show_items () {
            /* Resets the list */
            foreach (var child in get_children ()) {
                this.remove (child);
            }

            this.add (motion_revealer);

            foreach (var entry in this.window.order_service.get_order ()) {
                if (entry.type == Order.Type.REQUEST) {
                    var request = this.window.request_service.get_request_by_id (entry.id);

                    if (request != null) {
                        if (request.collection_id != null) continue;
                        this.add_request (request);
                    } else {
                        error ("NO REQUEST FOUND\n");
                    }
                } else if (entry.type == Order.Type.COLLECTION) {
                    var collection = this.window.collection_service.get_collection_by_id (entry.id);

                    if (collection != null) {
                        this.add_collection (collection);
                    } else {
                        error ("NO COLLECTION FOUND\n");
                    }
                }
            }
        }

        public void add_request (Models.Request request) {
            var request_list_item = new RequestListItem (request.id, request.name, request.uri, request.method);
            request_list_item.activate_drag_and_drop ();

            this.add (request_list_item);
            this.request_items[request.id] = request_list_item;

            request_list_item.clicked.connect (() => {
                this.select_request (request.id);
                this.request_item_selected (request.id);
            });

            request_list_item.edit_clicked.connect (() => {
                this.request_edit_clicked (request.id);
            });

            request_list_item.clone_clicked.connect (() => {
                this.request_clone_clicked (request.id);
            });

            request_list_item.delete_clicked.connect (() => {
                this.request_items.unset (request.id);
                this.request_delete_clicked (request.id);
            });

            request_list_item.request_appended.connect ((dropped_id) => {
                this.request_moved (request.id, dropped_id);
            });

            request_list_item.show_all();
        }

        public void add_collection (Models.Collection collection) {
            var dropdown = new Dropdown (collection);

            dropdown.item_edit.connect ((request) => {
                item_edit (request);
            });

            dropdown.request_item_selected.connect ((id) => {
                this.select_request (id);
                this.request_item_selected (id);
            });

            dropdown.request_edit_clicked.connect ((id) => {
                this.request_edit_clicked (id);
            });

            dropdown.request_clone_clicked.connect ((id) => {
                this.request_clone_clicked (id);
            });

            dropdown.item_deleted.connect ((request) => {
                item_deleted (request);
            });

            dropdown.create_collection_request.connect ((collection_id) => {
                this.create_collection_request (collection_id);
            });

            dropdown.collection_edit.connect ((collection) => {
                collection_edit (collection);
            });

            dropdown.collection_delete.connect (() => {
                bool contains_active_request = false;

                foreach (var request_id in collection.request_ids) {
                    if (request_id == this.active_id) {
                        contains_active_request = true;
                        break;
                    }
                }
                collection_delete (collection.id, contains_active_request);
            });

            dropdown.request_moved.connect ((target_id, moved_id) => {
                this.request_moved_after_collection_request (target_id, moved_id, collection.id);
            });

            dropdown.request_dropped.connect ((id) => {
                this.collection_visiblity[collection.id] = true;
                dropdown.expanded = true;
                this.request_added_to_collection (collection.id, id);
            });

            dropdown.change_visibility.connect((visible) => {
                this.collection_visiblity[collection.id] = visible;
            });

            foreach (var request_id in collection.request_ids) {
                var request = this.window.request_service.get_request_by_id (request_id);

                if (request != null) {
                    this.request_items[request.id] = dropdown.add_request (request);
                }
            }

            // If collection is new, make it initially visible
            if (!this.collection_visiblity.has_key(collection.id)) {
                this.collection_visiblity[collection.id] = true;
            }

            dropdown.expanded = this.collection_visiblity[collection.id];

            this.add (dropdown);
        }
    }
}
