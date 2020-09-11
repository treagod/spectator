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
        public signal void create_collection_request (uint id);
        public signal void collection_edit (Models.Collection collection);
        public signal void collection_delete (Models.Collection collection);

        public uint? active_id { get; private set; }
        private Gee.HashMap<uint, RequestListItem> request_items;
        private Spectator.Window window;

        construct {
            orientation = Gtk.Orientation.VERTICAL;
            spacing = 3;
        }

        public Container (Spectator.Window window) {
            this.window = window;
            this.active_id = null;
            this.request_items = new Gee.HashMap<uint, RequestListItem> ();
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
        }

        public void unselect_all () {
            @foreach ((child) => {
                var dropdown = (Dropdown) child;

                dropdown.unselect_all ();
                //  if (!dropdown.collection.items_visible) {
                //      dropdown.expanded = false;
                //  }
            });
        }

        public void update_active_method (Models.Method method) {
            var active_item = this.request_items[active_id];

            if (active_item != null) {
                active_item.set_method (method);
            }
        }

        public void update_active_url (string url) {
            var active_item = this.request_items[active_id];

            if (active_item != null) {
                active_item.set_url (url);
            }
        }

        //  public void adjust_visibility () {
        //      foreach (var child in get_children ()) {
        //          var dropdown = (Dropdown) child;
        //          dropdown.adjust_visibility ();
        //      }
        //  }

        //  public void update (Models.Collection collection) {
        //      foreach (var child in get_children ()) {
        //          var dropdown = (Dropdown) child;

        //          if (dropdown.collection == collection) {
        //              dropdown.update ();
        //              break;
        //          }
        //      }
        //  }

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

            this.add (request_list_item);
            this.request_items[request.id] = request_list_item;

            request_list_item.clicked.connect (() => {
                select_request (request.id);
                this.request_item_selected (request.id);
            });
            show_all();
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

            dropdown.item_clone.connect ((request) => {
                item_clone (request);
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

            dropdown.collection_delete.connect ((collection) => {
                dropdown.destroy ();
                remove (dropdown);
                collection_delete (collection);
            });

            foreach (var request_id in collection.request_ids) {
                var request = this.window.request_service.get_request_by_id (request_id);

                if (request != null) {
                    this.request_items[request.id] = dropdown.add_request (request);
                }
            }

            this.add (dropdown);
        }
    }
}
