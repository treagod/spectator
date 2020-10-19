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

namespace Spectator.Dialogs.Preference {
    /* TODO: Unify tab content */
    public class Editor : Gtk.Box {
        construct {
            orientation = Gtk.Orientation.VERTICAL;
            margin = 5;
        }

        public Editor () {
            var option_grid = new Gtk.Grid ();
            var settings = Settings.get_instance ();

            var font_label = new Gtk.Label (_("Font"));
            font_label.halign = Gtk.Align.START;
            var font_button = new Gtk.FontButton ();
            font_button.font = settings.font;
            font_button.font_set.connect (() => {
                settings.font = font_button.font;
                settings.font_changed ();
            });

            var use_default_font_label = new Gtk.Label (_("Use Default Font"));
            use_default_font_label.halign = Gtk.Align.START;
            var use_default_font_switch = new Gtk.Switch ();
            use_default_font_switch.halign = Gtk.Align.END;
            use_default_font_switch.active = settings.use_default_font;
            use_default_font_switch.state_set.connect (() => {
                if (use_default_font_switch.active) {
                    settings.default_font ();
                } else {
                    settings.font_changed ();
                }
                font_button.sensitive = !use_default_font_switch.active;
                settings.use_default_font = use_default_font_switch.active;
                return true;
            });


            option_grid.column_spacing = 12;
            option_grid.row_spacing = 6;

            var scheme_label = new Gtk.Label (_("Color Scheme"));
            scheme_label.halign = Gtk.Align.START;
            scheme_label.valign = Gtk.Align.START;

            var fbox = new Gtk.FlowBox ();
            fbox.max_children_per_line = 1;
            fbox.column_spacing = 0;

            var tree_view = this.editor_style_tree_view ();

            option_grid.attach (use_default_font_label, 0, 0, 1, 1);
            option_grid.attach (use_default_font_switch, 1, 0, 1, 1);
            option_grid.attach (font_label, 0, 1, 1, 1);
            option_grid.attach (font_button, 1, 1, 1, 1);
            option_grid.attach (scheme_label, 0, 2, 1, 1);
            option_grid.attach (tree_view, 1, 2, 1, 1);

            add (option_grid);
        }

        private Gtk.TreeView editor_style_tree_view () {
            var tree_view = new Gtk.TreeView ();
            var list_store = new Gtk.ListStore (1, typeof (string));
            var settings = Settings.get_instance ();

            tree_view.set_model (list_store);
            tree_view.set_headers_visible (false);

            tree_view.insert_column_with_attributes (-1, _("Editor Styles"), new Gtk.CellRendererText (), "text", 0, null);

            Gtk.TreeIter iter;
            var scheme_manager = Gtk.SourceStyleSchemeManager.get_default ();

            foreach (var id in scheme_manager.scheme_ids) {
                list_store.append (out iter);
                list_store.set (iter, 0, this.create_label_for_id (id));

                if (id == settings.editor_scheme) {
                    tree_view.get_selection ().select_iter (iter);
                }
            }

            tree_view.get_selection ().changed.connect ((tree_selection) => {
                Gtk.TreeModel model;
                Gtk.TreeIter iter2;
                string label;

                if (tree_selection.get_selected (out model, out iter2)) {
                    model.get (iter2, 0, out label);


                    settings.editor_scheme = this.create_id_from_label (label);
                    settings.editor_scheme_changed ();
                }
            });

            return tree_view;
        }

        private string create_id_from_label (string label) {
            var label_parts = label.split (" ");
            var id_builder = new StringBuilder ();
            bool first = true;

            foreach (var part in label_parts) {
                if (first) {
                    first = false;
                } else {
                    id_builder.append_c ('-');
                }
                id_builder.append (part.down());
            }

            return id_builder.str.strip ();
        }

        private string create_label_for_id (string id) {
            var part_ids = id.split ("-");
            var builder = new StringBuilder ();

            foreach (var part in part_ids) {
                part = "%s%s ".printf (part.up (1), part.substring (1));
                builder.append (part);
            }

            return builder.str.strip ();
        }
    }
}
