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
        private static string collection_open_icon = "folder-open";
        private static string collection_closed_icon = "folder";

        private Models.Collection collection;
        private Gtk.Label label;
        private Gtk.Box box;
        private Gtk.Box item_box;
        private Gtk.Image indicator;
        private Gee.ArrayList<Item> items;
        private bool _expanded;
        public bool expanded {
            get {
                return _expanded;
            }
            set {
                _expanded = value;
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

        public Dropdown (Models.Collection model) {
            collection = model;
            items = new Gee.ArrayList<Item> ();

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
            });

            box.add (indicator);
            box.add (label);
            var event_box = new Gtk.EventBox ();
            event_box.add (box);
            event_box.button_release_event.connect (() => {
                expanded = !expanded;
                return true;
            });
            add (event_box);
            add (item_box);


            show_all ();
            item_box.hide ();
        }
    }
}