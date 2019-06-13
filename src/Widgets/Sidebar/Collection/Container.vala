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
        public signal void item_deleted (Models.Request request);
        public signal void item_clicked (Item item);
        public signal void create_collection_request (Models.Collection collection);
        public signal void collection_edit (Models.Collection collection);

        private Item? active_item;

        construct {
            orientation = Gtk.Orientation.VERTICAL;
            spacing = 3;
        }

        public Container () {
            get_style_context ().add_class ("collection-box");
        }

        public void adjust_visibility () {
            foreach (var child in get_children()) {
                var dropdown = (Dropdown) child;
                dropdown.adjust_visibility ();
            }
        }

        public void add_collection (Models.Collection collection) {
            var dropdown = new Dropdown (collection);

            dropdown.item_edit.connect ((request) => {
                item_edit (request);
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