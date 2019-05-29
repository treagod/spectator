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
    public class Dropdown : Gtk.EventBox {
        private Models.Collection collection;
        private Gtk.Label label;
        private Gtk.Box box;
        private Gtk.Image indicator;
        private bool _expanded;
        public bool expanded {
            get {
                return _expanded;
            }
            set {
                _expanded = value;
                if (_expanded) {
                    indicator.set_from_icon_name ("folder-open", Gtk.IconSize.BUTTON);
                } else {
                    indicator.set_from_icon_name ("folder", Gtk.IconSize.BUTTON);
                }
            }
        }

        public Dropdown (Models.Collection model) {
            collection = model;
            box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 4);
            label = new Gtk.Label ("<b>%s</b>".printf (collection.name));
            label.halign = Gtk.Align.START;
            label.use_markup = true;
            indicator = new Gtk.Image.from_icon_name ("folder", Gtk.IconSize.BUTTON);;
            _expanded = false;

            box.add (indicator);
            box.add (label);
            add (box);

            button_release_event.connect (() => {
                expanded = !expanded;
                return true;
            });
            show_all ();
        }
    }
}