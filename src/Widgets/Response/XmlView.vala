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
    class XmlView : AbstractTypeView {
        private SourceView response_text;
        private SourceView response_text_raw;
        private XmlTreeView tree_view;
        private HeaderList header_list;
        private Gtk.ScrolledWindow scrolled;
        private Gtk.ScrolledWindow scrolled_raw;
        private Gtk.ScrolledWindow tree_scrolled;
        private Gtk.ScrolledWindow header_scrolled;

        public XmlView () {
            tree_view = new XmlTreeView.empty ();
            header_list = new HeaderList ();
            scrolled = new Gtk.ScrolledWindow (null, null);
            scrolled_raw = new Gtk.ScrolledWindow (null, null);
            tree_scrolled = new Gtk.ScrolledWindow (null, null);
            header_scrolled = new Gtk.ScrolledWindow (null, null);
            response_text = new SourceView ();
            response_text_raw = new SourceView ();
            scrolled.add (response_text);
            scrolled_raw.add (response_text_raw);
            tree_scrolled.add (tree_view);
            header_scrolled.add (header_list);

            response_text.set_lang ("xml");
            response_text_raw.set_lang ("plain");


            add (tree_scrolled);
            add (header_scrolled);
            add (scrolled);
            add (scrolled_raw);

            set_visible_child (header_scrolled);

            show_all ();
        }

        public override void show_view (int i) {
            switch (i) {
                case 1:
                    set_visible_child (scrolled);
                    break;
                case 2:
                    set_visible_child (header_scrolled);
                    break;
                case 3:
                    set_visible_child (scrolled_raw);
                    break;
                default:
                    set_visible_child (tree_scrolled);
                    break;
            }
        }

        private string pretty_xml (string xml) {
            var pretty_xml = "";
            Xml.Parser.init ();
            Xml.Doc* doc = Xml.Parser.parse_doc (xml);
            if (doc == null) {
                stderr.printf ("Could not parse\n");
                return xml;
            }
            doc->dump_memory_enc_format (out pretty_xml);
            delete doc;

            Xml.Parser.cleanup ();

            return pretty_xml;
        }

        public override void update (Models.Response? it) {
            if (it == null) {
                response_text.insert_text ("");
                response_text_raw.insert_text ("");
                tree_view.clear ();
                return;
            }

            header_list.clear ();

            foreach (var entry in it.headers.entries) {
                header_list.add_header (entry.key, entry.value);
            }

            header_list.show_all ();
            tree_view.update_from_string (it.data);

            response_text.insert_text (pretty_xml (it.data));
            response_text_raw.insert_text (it.raw);
        }
    }
}
