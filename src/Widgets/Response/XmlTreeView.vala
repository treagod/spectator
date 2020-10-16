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

namespace Spectator.Widgets.Response {
    public class XmlTreeView : Gtk.TreeView {
        // Workaround to keep Gtk.TreeIter in memory to do recursive creation
        private class TreeIter {
            public Gtk.TreeIter iter;
        }

        private Gtk.TreeStore store;

        private XmlTreeView () {}

        public XmlTreeView.from_string (string xml) {
            Xml.Parser.init ();
            var doc = Xml.Parser.parse_doc (xml);
            if (doc == null) {
                stderr.printf ("Could not parse\n");
            }
            var root = doc->get_root_element ();

            if (root != null) {
                init_tree (root);
            } else {
                init_empty ();
            }

            delete doc;

            Xml.Parser.cleanup ();
            expand_all ();
        }

        public XmlTreeView.empty () {
            init_empty ();
        }

        private void init_empty () {
            store = new Gtk.TreeStore (2, typeof (string), typeof (string));
            set_model (store);
            insert_column_with_attributes (-1, "Key", new Gtk.CellRendererText (), "text", 0, null);
            insert_column_with_attributes (-1, "Value", new Gtk.CellRendererText (), "text", 1, null);
        }

        public void clear () {
            store.clear ();
        }

        public void update_from_string (string xml) {
            clear ();

            Xml.Parser.init ();
            var doc = Xml.Parser.parse_doc (xml);
            if (doc == null) {
                stderr.printf ("Could not parse\n");
            }
            var root = doc->get_root_element ();

            if (root != null) {
                init_top_level (root);
            }

            delete doc;

            Xml.Parser.cleanup ();
            expand_all ();
        }

        private void init_tree (Xml.Node* node) {
            init_empty ();

            init_top_level (node);
        }

        private void init_top_level (Xml.Node* node) {
            var root = new TreeIter ();

            store.append (out root.iter, null);

            if (node->type == Xml.ElementType.ELEMENT_NODE) {
                store.set (root.iter, 0, node->name, 1, "", -1);
                add_object_content (node, root);
            }
        }

        private void add_object_content (Xml.Node* node, TreeIter parent) {
            var iter = new TreeIter ();
            var text_as_property = false;
            store.append (out iter.iter, parent.iter);

            var doc = node->doc;
            var content = doc->node_list_get_string (node->children, true);
            if (content != null && content != "") {
                if (node->properties != null) {
                    text_as_property = true;
                    store.set (iter.iter, 0, node->name, 1, "", -1);
                } else {
                    store.set (iter.iter, 0, node->name, 1, content, -1);
                }
            } else {
                store.set (iter.iter, 0, node->name, 1, "", -1);
            }

            for (Xml.Node* child = node->children; child != null; child = child->next) {
                if (child->type == Xml.ElementType.ELEMENT_NODE) {
                    add_object_content (child, iter);
                }
            }
            for (Xml.Attr* attr = node->properties; attr != null; attr = attr->next) {
                add_object_attribute (attr, iter);
            }

            if (text_as_property) {
                var text_iter = new TreeIter ();
                store.append (out text_iter.iter, iter.iter);
                store.set (text_iter.iter, 0, "__text", 1, content, -1);
            }
        }

        private void add_object_attribute (Xml.Attr* attr, TreeIter parent) {
            var iter = new TreeIter ();
            var doc = attr->doc;
            var val = doc->node_list_get_string (attr->children, true);

            store.append (out iter.iter, parent.iter);
            store.set (iter.iter, 0, "_%s".printf (attr->name), 1, val, -1);
        }
    }
}
