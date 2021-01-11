/*
* Copyright (c) 2021 Marvin Ahlgrimm (https://github.com/treagod)
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
    class DefaultView : AbstractTypeView {
        private SourceView response_text;
        private SourceView response_text_raw;
        private HeaderList header_list;
        private Gtk.ScrolledWindow scrolled;
        private Gtk.ScrolledWindow scrolled_raw;
        private Gtk.ScrolledWindow header_scrolled;

        public DefaultView () {
            header_list = new HeaderList ();
            scrolled = new Gtk.ScrolledWindow (null, null);
            scrolled_raw = new Gtk.ScrolledWindow (null, null);
            header_scrolled = new Gtk.ScrolledWindow (null, null);
            response_text = new SourceView ();
            response_text.set_lang ("plain");
            response_text_raw = new SourceView ();
            response_text_raw.set_lang ("plain");
            scrolled.add (response_text);
            scrolled_raw.add (response_text_raw);
            header_scrolled.add (header_list);
            add (header_scrolled);
            add (scrolled);
            add (scrolled_raw);

            set_visible_child (scrolled);

            show_all ();
        }

        public override void show_view (int i) {
            switch (i) {
                case 0:
                    set_visible_child (scrolled);
                    break;
                default:
                    set_visible_child (scrolled_raw);
                    break;
            }
        }

        public override void update (Models.Response? it) {
            if (it == null) {
                 response_text.buffer.text = "";
                 response_text_raw.buffer.text = "";
                return;
            }

            header_list.clear ();

            foreach (var entry in it.headers.entries) {
                header_list.add_header (entry.key, entry.value);
            }

            header_list.show_all ();
            response_text.buffer.text = it.data;
            response_text_raw.buffer.text = it.raw;
        }
    }
}
