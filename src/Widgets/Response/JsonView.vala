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

namespace HTTPInspector.Widgets.Response {
    class JsonView : AbstractTypeView {
        private SourceView response_text;
        private SourceView response_text_raw;
        private Gtk.ScrolledWindow scrolled;
        private Gtk.ScrolledWindow scrolled_raw;

        public JsonView () {
            var test = new JsonTreeView.parse_string ("{\"key\": \"value\"}");//"{\"asd\": 1}");
            scrolled = new Gtk.ScrolledWindow (null, null);
            scrolled_raw = new Gtk.ScrolledWindow (null, null);
            response_text = new SourceView ();
            response_text_raw = new SourceView ();
            scrolled.add (test);
            scrolled_raw.add (response_text_raw);

            response_text.set_lang ("json");

            add_named (scrolled, "response_text");
            add_named (scrolled_raw, "response_text_raw");

            set_visible_child (scrolled);

            show_all ();
        }

        public override void show_view (int i) {
            switch (i) {
                case 1:
                    set_visible_child (scrolled_raw);
                    break;
                default:
                    set_visible_child (scrolled);
                    break;
            }
        }

        public override void update (ResponseItem? it) {
            if (it == null) {
                response_text.insert_text ("");
                response_text_raw.insert_text ("");
                return;
            }

            try {
                // Pretty Print Version of response JSON
                var parser = new Json.Parser ();
                var json = convert_with_fallback (it.data, it.data.length, "UTF-8", "ISO-8859-1");
                parser.load_from_data (json, -1);
                var root = parser.get_root ();
                var generator = new Json.Generator ();
                generator.set_root (root);
                generator.indent = 4;
                generator.pretty = true;
                var pretty_json = generator.to_data (null);
                response_text.insert_text (pretty_json);
            } catch (Error e) {
                stderr.printf ("Error parsing JSON.\n");
            }

            response_text_raw.insert_text (it.raw);
        }
    }
}
