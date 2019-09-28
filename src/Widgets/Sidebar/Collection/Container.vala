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

namespace Spectator.Widgets.Sidebar.Collection {
    public class Container : Gtk.Box {
        public signal void item_edit (Models.Request request);
        public signal void item_clone (Models.Request request);
        public signal void item_deleted (Models.Request request);
        public signal void item_clicked (Item item);
        public signal void create_collection_request (Models.Collection collection);
        public signal void collection_edit (Models.Collection collection);
        public signal void collection_delete (Models.Collection collection);

        public Item? active_item { get; private set; }

        construct {
            orientation = Gtk.Orientation.VERTICAL;
            spacing = 3;
        }

        public Container () {
            get_style_context ().add_class ("collection-box");

            Settings.get_instance ().theme_changed.connect (() => {
                @foreach ((child) => {
                    var dropdown = (Dropdown) child;

                    dropdown.each_item ((item) => {
                        item.refresh ();
                    });
                });
            });
        }

        public void change_active (Models.Request request) {
            if (active_item != null) {
                active_item.get_style_context ().remove_class ("active");
                active_item = null;
            }

            @foreach ((child) => {
                var dropdown = (Dropdown) child;
                var item = dropdown.get_item (request);

                if (item != null) {
                    active_item = item;
                    active_item.get_style_context ().add_class ("active");
                    return;
                }
            });
        }

        public void unselect_all () {
            @foreach ((child) => {
                var dropdown = (Dropdown) child;

                dropdown.unselect_all ();
                if (!dropdown.collection.items_visible) {
                    dropdown.expanded = false;
                }
            });
        }

        public void update_active_url () {
            if (active_item != null) {
                active_item.update_url ();
            }
        }

        public void adjust_visibility () {
            foreach (var child in get_children ()) {
                var dropdown = (Dropdown) child;
                dropdown.adjust_visibility ();
            }
        }

        public void update (Models.Collection collection) {
            foreach (var child in get_children ()) {
                var dropdown = (Dropdown) child;

                if (dropdown.collection == collection) {
                    dropdown.update ();
                    break;
                }
            }
        }

        public void add_collection (Models.Collection collection) {
            var dropdown = new Dropdown (collection);

            dropdown.item_edit.connect ((request) => {
                item_edit (request);
            });

            dropdown.item_clone.connect ((request) => {
                item_clone (request);
            });

            dropdown.item_deleted.connect ((request) => {
                item_deleted (request);
            });

            dropdown.item_clicked.connect ((item) => {
                if (active_item != null) {
                    active_item.get_style_context ().remove_class ("active");
                }
                active_item = item;
                active_item.get_style_context ().add_class ("active");
                item_clicked (item);
            });

            dropdown.create_collection_request.connect ((collection) => {
                create_collection_request (collection);
            });

            dropdown.collection_edit.connect ((collection) => {
                collection_edit (collection);
            });

            dropdown.collection_delete.connect ((collection) => {
                collection_delete (collection);
                dropdown.destroy ();
                remove (dropdown);
            });

            dropdown.active_item_changed.connect ((item) => {
                if (active_item != null) {
                    active_item.get_style_context ().remove_class ("active");
                }
                active_item = item;
                active_item.get_style_context ().add_class ("active");
            });

            add (dropdown);
        }
    }
}
