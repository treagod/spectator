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
        // Workaround to keep Gtk.TreeIter in memory to do recursive creation
        private class TreeIter {
            public Gtk.TreeIter iter;
        }

        private Gtk.TreeStore store;

        public JsonTreeView (Json.Node node) {
            init_tree (node);
            expand_all ();
        }

        public JsonTreeView.from_string (string json) {
            try {
                var parser = new Json.Parser ();
                parser.load_from_data (json);
                init_tree (parser.get_root ());
            } catch (Error e) {
                print ("Unable to parse the string: %s\n", e.message);
            }
            expand_all ();
        }

        public JsonTreeView.empty () {
            store = new Gtk.TreeStore (2, typeof (string), typeof (string));
            set_model (store);
            insert_column_with_attributes (-1, "Key", new Gtk.CellRendererText (), "text", 0, null);
            insert_column_with_attributes (-1, "Value", new Gtk.CellRendererText (), "text", 1, null);
        }

        public void clear () {
            store.clear ();
        }

        public void update_from_string (string json) {
            clear ();

            try {
                var parser = new Json.Parser ();
                parser.load_from_data (json);

                init_top_level (parser.get_root ());
            } catch (Error e) {
                print ("Unable to parse the string: %s\n", e.message);
            }
            expand_all ();
        }

        private void init_tree (Json.Node node) {
            store = new Gtk.TreeStore (2, typeof (string), typeof (string));
            set_model (store);
            insert_column_with_attributes (-1, "Key", new Gtk.CellRendererText (), "text", 0, null);
            insert_column_with_attributes (-1, "Value", new Gtk.CellRendererText (), "text", 1, null);

            init_top_level (node);
        }

        private void init_top_level (Json.Node node) {
            var root = new TreeIter ();

            store.append (out root.iter, null);

            if (node.get_node_type () == Json.NodeType.OBJECT) {
                store.set (root.iter, 0, "Object", 1, "", -1);
                add_object_content (node.get_object (), root);
            } else if (node.get_node_type () == Json.NodeType.ARRAY) {
                store.set (root.iter, 0, "Array", 1, "", -1);
                add_array_content (node.get_array (), root);
            } else if (node.is_null ()) {
                store.set (root.iter, 0, "", 1, "null", -1);
            } else {
                add_key_value ("", node, root);
            }
        }

        private void add_object_content (Json.Object object, TreeIter parent) {
            var iter = new TreeIter ();

            object.foreach_member ((object, key, node) => {
                store.append (out iter.iter, parent.iter);
                add_key_value (key, node, iter);
            });
        }

        private void add_array_content (Json.Array array, TreeIter parent) {
            var iter = new TreeIter ();

            array.foreach_element ((array, idx, node) => {
                store.append (out iter.iter, parent.iter);
                add_key_value ("%u".printf (idx), node, iter);
            });
        }

        private void add_key_value (string key, Json.Node node, TreeIter iter) {
            if (node.get_node_type () == Json.NodeType.OBJECT) {
                store.set (iter.iter, 0, key, 1, "", -1);
                add_object_content (node.get_object (), iter);
            } else if (node.get_node_type () == Json.NodeType.ARRAY) {
                store.set (iter.iter, 0, key, 1, "", -1);
                add_array_content (node.get_array (), iter);
            } else if (node.is_null ()) {
                store.set (iter.iter, 0, key, 1, "null", -1);
            } else {
                add_value (key, node.get_value (), iter);
            }
        }

        private void add_value (string key, Value val, TreeIter iter) {
            switch (val.type ()) {
            case Type.INT64:
                store.set (iter.iter, 0, key, 1, (("%" + int64.FORMAT + "").printf (val.get_int64 ())), -1);
                break;
            case Type.INT:
                store.set (iter.iter, 0, key, 1, ("%d".printf (val.get_int ())), -1);
                break;
            case Type.DOUBLE:
                store.set (iter.iter, 0, key, 1, val.get_double ().to_string (), -1);
                break;
            case Type.INVALID:
                store.set (iter.iter, 0, key, 1, "INVALID", -1);
                break;
            case Type.NONE:
                store.set (iter.iter, 0, key, 1, "null", -1);
                break;
            case Type.BOOLEAN:
                store.set (iter.iter, 0, key, 1, val.get_boolean ().to_string (), -1);
                break;
            default:
                store.set (iter.iter, 0, key, 1, val.get_string (), -1);
                break;
            }
        }
    }
}
