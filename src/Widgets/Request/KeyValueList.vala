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
    class KeyValueList : Gtk.Box {
        private Gtk.Grid rows;
        private uint id;

        public signal void item_deleted (Pair header);
        public signal void item_added (Pair header);

        public KeyValueList (string add_label) {
            orientation = Gtk.Orientation.VERTICAL;
            margin_left = 7;
            margin_right = 7;
            id = 0;

            rows = new Gtk.Grid ();
            rows.column_spacing = 3;
            rows.row_spacing = 3;
            var add_row_button = new Gtk.Button.with_label (add_label);

            add_row_button.margin_top = 7;
            add_row_button.margin_left = 128;
            add_row_button.margin_right = 128;

            add_row_button.clicked.connect (() => {
                add_row ();
            });


            add (rows);
            add (add_row_button);
        }

        public void change_rows (Gee.ArrayList<Pair> items) {
            rows.forall ((widget) => {
                rows.remove (widget);
            });

            foreach (var item in items) {
                add_field (item);
            }
        }

        public void add_field (Pair header) {
            var header_field = new HeaderField.with_value (header);
            var del_button = new Gtk.Button.from_icon_name ("window-close");

            del_button.clicked.connect (() => {
                item_deleted (header_field.header);
                rows.remove (header_field);
                rows.remove (del_button);
            });

            rows.attach (header_field, 0, (int) id, 1, 1);
            rows.attach (del_button, 2, (int) id, 1, 1);

            id++;
            show_all ();
        }

        public void add_row () {
            var header_field = new HeaderField ();
            var del_button = new Gtk.Button.from_icon_name ("window-close");

            del_button.clicked.connect (() => {
                item_deleted (header_field.header);
                rows.remove (header_field);
                rows.remove (del_button);
            });

            rows.attach (header_field, 0, (int) id, 1, 1);
            rows.attach (del_button, 2, (int) id, 1, 1);

            item_added (header_field.header);
            id++;
            show_all ();
        }
    }
}
