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

namespace HTTPInspector {
    class HeaderView : Gtk.Box {
        private List<Gtk.Button> buttons;
        public Gee.ArrayList<HeaderField> headers;
        private Gtk.Grid header_fields;
        private RequestItem item;

        public HeaderView () {
            orientation = Gtk.Orientation.VERTICAL;
            margin_left = 7;
            margin_right = 7;

            header_fields = new Gtk.Grid ();
            buttons = new List<Gtk.Button> ();
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

        public void update_item (RequestItem it) {
            item = it;

            if (item.headers.size == 0) {
                item.add_header ("", "");
            }

            int i = 0;
            foreach (var header in item.headers) {
                add_header_row (header, i);
                i++;
            }
        }

        private void queue_button (Gtk.Button button) {
            buttons.append (button);
            button.clicked.connect (() => {
                var index = buttons.index (button);
                buttons.remove (button);
                header_fields.remove_row (index + 1);

                if (buttons.length () == 0) {
                    add_row ();
                }
            });
        }

        public void add_row () {
            var header_field = new HeaderField (0);
            var del_button = new Gtk.Button.from_icon_name ("window-close");

            queue_button (del_button);

            headers.add (header_field);

            header_fields.attach (header_field, 0, (int) buttons.length (), 1, 1);
            header_fields.attach (del_button, 2, (int) buttons.length (), 1, 1);
            show_all ();
        }

        public void add_header_row (Header header, int index) {
            var header_field = new HeaderField (index);
            header_field.set_header (header.key, header.val);
            var del_button = new Gtk.Button.from_icon_name ("window-close");

            item.add_header (header.key, header.val);

            queue_button (del_button);

            headers.add (header_field);

            header_fields.attach (header_field, 0, (int) buttons.length (), 1, 1);
            header_fields.attach (del_button, 2, (int) buttons.length (), 1, 1);
            show_all ();
        }
    }
}
