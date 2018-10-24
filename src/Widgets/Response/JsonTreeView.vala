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
    public class JsonTreeView  : Gtk.TreeView {
        private Gtk.TreeStore store;
        public JsonTreeView (Json.Node node) {
            init_tree (node);
        }

        public JsonTreeView.parse_string (string json) {
            var parser = new Json.Parser ();
            try {

                parser.load_from_data (json);
                init_tree (parser.get_root ());
            } catch (Error e) {
                print ("Unable to parse the string: %s\n", e.message);
            }
        }

        private void init_tree (Json.Node node) {
            var store = new Gtk.TreeStore (2, typeof (string), typeof (string));
            set_model (store);
            insert_column_with_attributes (-1, "Key", new Gtk.CellRendererText (), "text", 0, null);
            insert_column_with_attributes (-1, "Value", new Gtk.CellRendererText (), "text", 1, null);
            Gtk.TreeIter root;

            if (node.get_node_type () == Json.NodeType.OBJECT) {
                store.append (out root, null);
                store.set (root, 0, "Object", 1, "", -1);
            } else if (node.get_node_type () == Json.NodeType.ARRAY) {
                store.append (out root, null);
                store.set (root, 0, "Array", 1, "", -1);
            } else {
                var val = node.get_value ();

                switch (val.type ()) {
                case Type.INT64:
                    store.append (out root, null);
                    store.set (root, 0, "", 1, (("%" + int64.FORMAT + "").printf (val.get_int64 ())), -1);
                    break;
                case Type.INT:
                    store.append (out root, null);
                    store.set (root, 0, "", 1, ("%d".printf (val.get_int ())), -1);
                    break;
                default:
                    store.append (out root, null);
                    store.set (root, 0, "", 1, node.get_string (), -1);
                    break;
                }

                return;
            }
        }

        private owned Gtk.TreeIter add_object_content (Json.Object object, Gtk.TreeIter parent) {
            Gtk.TreeIter iter;

            store.append (out iter, parent);
            store.set (iter, 0, "test", 1, "maeh", -1);

            return iter;
        }

        private void add_value (Value val, Gtk.TreeIter iter) {

        }
    }
}
