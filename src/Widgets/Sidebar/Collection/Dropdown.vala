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
    public class Dropdown : Gtk.Box {
        public delegate void ItemIterator (Item item);
        private static string collection_open_icon = "folder-open";
        private static string collection_closed_icon = "folder";

        public signal void item_edit (Models.Request request);
        public signal void item_deleted (Models.Request request);
        public signal void item_clicked (Item item);
        public signal void collection_delete (Models.Collection collection);
        public signal void collection_edit (Models.Collection collection);
        public signal void create_collection_request (Models.Collection collection);
        public signal void active_item_changed (Item item);

        public Models.Collection collection { get; private set;}
        private Gtk.Label label;
        private Gtk.Box box;
        private Gtk.Box item_box;
        private Gtk.Image indicator;
        private bool _expanded;
        public bool expanded {
            get {
                return _expanded;
            }
            set {
                _expanded = value;
                collection.items_visible = value;
                if (_expanded) {
                    indicator.set_from_icon_name (collection_open_icon, Gtk.IconSize.BUTTON);
                    item_box.show ();
                } else {
                    indicator.set_from_icon_name (collection_closed_icon, Gtk.IconSize.BUTTON);
                    item_box.hide ();
                }
            }
        }

        construct {
            orientation = Gtk.Orientation.VERTICAL;
            spacing = 0;
        }

        public void update () {
            label.label = "<b>%s</b>".printf (collection.name);
        }

        public Item? get_item (Models.Request request) {
            Item? result = null;
            item_box.foreach ((it) => {
                var item = (Item) it;

                if (item.item == request) {
                    result = item;
                    return;
                }
            });
            return result;
        }

        public void each_item (ItemIterator iter) {
            item_box.foreach ((it) => {
                var item = (Item) it;

                iter (item);
            });
        }

        public void unselect_all () {
            item_box.foreach ((it) => {
                var item = (Item) it;

                item.get_style_context ().remove_class ("active");
            });
        }

        public Dropdown (Models.Collection model) {
            collection = model;
            box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 4);
            item_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 2);
            item_box.get_style_context ().add_class ("collection-items");
            label = new Gtk.Label ("<b>%s</b>".printf (collection.name));
            label.halign = Gtk.Align.START;
            label.use_markup = true;
            indicator = new Gtk.Image.from_icon_name (collection_open_icon, Gtk.IconSize.BUTTON);;
            _expanded = true;

            collection.request_added.connect ((request) => {
                var item = new Item (request);
                item_box.add (item);

                item.item_clicked.connect (() => {
                    item_clicked (item);
                });

                item.item_edit.connect ((item) => {
                    item_edit (item);
                });

                item.item_deleted.connect ((request) => {
                    item_deleted (request);
                    item_box.remove (item);
                    item = null;
                });

                active_item_changed (item);

                expanded = true;
                collection.items_visible = true;
                show_all ();
            });

            box.add (indicator);
            box.add (label);

            var event_box = create_event_box (model);

            add (event_box);
            add (item_box);


            show_all ();
            item_box.hide ();
        }

        public void adjust_visibility () {
            if (collection.items_visible) {
                expanded = true;
            } else {
                expanded = false;
            }
        }

        private Gtk.EventBox create_event_box (Models.Collection model) {
            var event_box = new Gtk.EventBox ();
            event_box.add (box);
            event_box.button_release_event.connect ((event) => {
                var result = false;
                switch (event.button) {
                    case 1:
                        expanded = !expanded;
                        result = true;
                        break;
                    case 3:
                        var menu = new Gtk.Menu ();
                        var new_request_item = new Gtk.MenuItem.with_label (_("Add Request"));
                        var edit_item = new Gtk.MenuItem.with_label (_("Edit"));
                        var delete_item = new Gtk.MenuItem.with_label (_("Delete"));

                        new_request_item.activate.connect (() => {
                            create_collection_request (model);
                        });

                        edit_item.activate.connect (() => {
                            collection_edit (model);
                        });

                        delete_item.activate.connect (() => {
                            collection_delete (model);
                        });

                        menu.add (new_request_item);
                        menu.add (new Gtk.SeparatorMenuItem ());
                        menu.add (edit_item);
                        menu.add (delete_item);
                        menu.show_all ();
                        menu.popup_at_pointer (event);
                        result = true;
                        break;
                    default:
                        break;
                }

                return result;
            });

            return event_box;
        }
    }
}