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

namespace Spectator.Widgets.Response {
    class HeaderList : Gtk.Grid {
        private int idx;
        public HeaderList () {
            idx = 0;
            column_spacing = 18;
            row_spacing = 5;
            margin_left = 25;
            margin_right = 25; // TODO: CSS!!
        }

        public void add_header (string key, string val) {
            var key_l = new Gtk.Label ("<b>%s</b>".printf (key));
            var val_l = new Gtk.Label (val);
            key_l.wrap_mode = Pango.WrapMode.CHAR;
            key_l.wrap = true;
            val_l.wrap_mode = Pango.WrapMode.CHAR;
            val_l.wrap = true;

            key_l.use_markup = true;

            key_l.selectable = true;
            val_l.selectable = true;

            key_l.halign = Gtk.Align.END;
            val_l.halign = Gtk.Align.START;
            key_l.hexpand = true;
            val_l.hexpand = true;
            attach (key_l, 0, idx, 1, 1);
            attach (val_l, 1, idx, 1, 1);
            idx++;
        }

        public void clear () {
            idx = 0;
            foreach (var child in get_children ()) {
                remove (child);
            }
        }
    }
}
