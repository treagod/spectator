/*
* Copyright (c) 2018 Marvin Ahlgrimm (https://github.com/treagod)
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

namespace HTTPInspector.Widgets.Request {
    class KeyValueField : Gtk.Box {
        private Gtk.Entry key_field;
        private Gtk.Entry value_field;
        public Pair item;

        public string key { get { return key_field.text; }}
        public string val { get { return value_field.text; }}

        public signal void updated (Pair item);

        construct {
            orientation = Gtk.Orientation.HORIZONTAL;
        }

        public KeyValueField () {
            item = new Pair ("", "");
            setup ();
        }

        public KeyValueField.with_value (Pair item) {
            this.item = item;
            setup ();

            key_field.text = item.key;
            value_field.text = item.val;

            key_field.changed.connect (() => { updated (item); });
            value_field.changed.connect (() => { updated (item); });
        }

        private void setup () {
            key_field = new Gtk.Entry ();
            value_field = new Gtk.Entry ();

            value_field.focus_out_event.connect (() => {
                // Only emit if both entries are filled
                if (key_field.text != "" && key_field.text != null) {
                    item.val = val;
                }

                return false;
            });

            value_field.changed.connect (() => {
                // Only emit if both entries are filled
                if (key_field.text != "" && key_field.text != null) {
                    item.val = val;
                }
            });

            key_field.focus_out_event.connect (() => {
                // Only emit if both entries are filled
                item.key = key;

                return false;
            });

            key_field.changed.connect (() => {
                item.key = key;
            });

            key_field.hexpand = true;
            value_field.hexpand = true;


            add (key_field);
            add (value_field);
        }
    }

}
