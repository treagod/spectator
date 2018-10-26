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
    class HeaderView : Gtk.Box {
        private Gee.ArrayList<Gtk.Button> buttons;
        public Gee.ArrayList<HeaderField> headers;
        private Gtk.Grid header_fields;
        private uint id;

        public signal void header_deleted (Header header);
        public signal void header_added (Header header);

        public HeaderView () {
            orientation = Gtk.Orientation.VERTICAL;
            margin_left = 7;
            margin_right = 7;
            id = 0;

            header_fields = new Gtk.Grid ();
            buttons = new Gee.ArrayList<Gtk.Button> ();
            headers = new Gee.ArrayList<HeaderField> ();
            header_fields.column_spacing = 3;
            header_fields.row_spacing = 3;
            var add_row_button = new Gtk.Button.with_label ("Add header");

            add_row_button.margin_top = 7;
            add_row_button.margin_left = 128;
            add_row_button.margin_right = 128;

            add_row_button.clicked.connect (() => {
                add_row ();
            });


            add (header_fields);
            add (add_row_button);
        }

        public void change_headers (Gee.ArrayList<Header> headers) {
            header_fields.forall ((widget) => {
                header_fields.remove (widget);
            });

            foreach (var header in headers) {
                add_header (header);
            }
        }

        public void add_header (Header header) {
            var header_field = new HeaderField.with_value (header);
            var del_button = new Gtk.Button.from_icon_name ("window-close");

            del_button.clicked.connect (() => {
                header_deleted (header_field.header);
                header_fields.remove (header_field);
                header_fields.remove (del_button);
            });

            headers.add (header_field);

            header_fields.attach (header_field, 0, (int) id, 1, 1);
            header_fields.attach (del_button, 2, (int) id, 1, 1);

            id++;
            show_all ();
        }

        public void add_row () {
            var header_field = new HeaderField ();
            var del_button = new Gtk.Button.from_icon_name ("window-close");

            del_button.clicked.connect (() => {
                header_deleted (header_field.header);
                header_fields.remove (header_field);
                header_fields.remove (del_button);
            });

            headers.add (header_field);

            header_fields.attach (header_field, 0, (int) id, 1, 1);
            header_fields.attach (del_button, 2, (int) id, 1, 1);

            header_added (header_field.header);
            id++;
            show_all ();
        }
    }
}
