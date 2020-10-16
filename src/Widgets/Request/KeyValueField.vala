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

namespace Spectator.Widgets.Request {
    public class KeyValueField : Gtk.Box {
        protected Gtk.Entry key_field;
        protected Gtk.Entry value_field;
        public Pair item;

        public string key { get { return key_field.text; }}
        public string val { get { return value_field.text; }}

        public signal void updated (Pair item);

        construct {
            orientation = Gtk.Orientation.HORIZONTAL;
        }

        public KeyValueField () {
            item = new Pair ("", "");
            key_field = new Gtk.Entry ();
            value_field = new Gtk.Entry ();
            setup ();
        }

        public KeyValueField.with_value (Pair item) {
            this.item = item;
            key_field = new Gtk.Entry ();
            value_field = new Gtk.Entry ();
            key_field.text = item.key;
            value_field.text = item.val;
            setup ();
        }

        private void setup () {
            value_field.changed.connect (() => {
                update_item ();
            });

            key_field.changed.connect (() => {
                update_item ();
            });

            key_field.hexpand = true;
            value_field.hexpand = true;


            add (key_field);
            add (value_field);
        }

        private void update_item () {
            item.key = key;
            item.val = val;
            updated (item);
        }
    }

}
