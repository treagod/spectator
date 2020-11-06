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
    public class ModeDropdown : Gtk.Box {
        private unowned Gtk.Stack stack;
        private Gtk.Label label;
        private Gtk.Popover popover;
        private Gtk.Box popover_box;
        private CurrentView _current_view;
        private static string TreeviewLabel = _("Treeview");
        private static string PrettifiedLabel = _("Prettified");
        private static string PlainLabel = _("Plain");

        public CurrentView current_view {
            get {
                return _current_view;
            }
            set {
                _current_view = value;
                switch(value) {
                    case CurrentView.JsonTreeView:
                    case CurrentView.XmlTreeView:
                    label.label = TreeviewLabel;
                    break;
                    case CurrentView.PrettifiedSourceView:
                    label.label = PrettifiedLabel;
                    break;
                    default:
                    label.label = PlainLabel;
                    current_view = CurrentView.SourceView;
                    break;
                }
            }
        }

        public enum DropdownItems {
            Json,
            Xml,
            Html,
            Other
        }

        construct {
            margin = 1;
            orientation = Gtk.Orientation.HORIZONTAL;
        }

        public ModeDropdown (Gtk.Stack stack) {
            this.stack = stack;
            label = new Gtk.Label ("Treeview");
            var down_arrow = new Gtk.Image.from_icon_name ("pan-down-symbolic", Gtk.IconSize.BUTTON);
            label.halign = Gtk.Align.CENTER;
            this.pack_start (label, true, true);
            this.pack_start (down_arrow, true, true);

            popover = new Gtk.Popover (this);
            popover_box = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
            popover.add(popover_box);
            popover.set_position(Gtk.PositionType.BOTTOM);
        }

        public void set_items (DropdownItems items) {
            foreach (var child in popover_box.get_children ()) {
                popover_box.remove (child);
            }

            switch (items) {
                case DropdownItems.Json:
                case DropdownItems.Xml:
                    var child_name = items == DropdownItems.Json ? "json_tree_view" : "xml_tree_view";

                    append_to_popover_box (create_model_button (TreeviewLabel, child_name));
                    append_to_popover_box (create_model_button (PrettifiedLabel, "prettified_view"));
                    append_to_popover_box (create_model_button (PlainLabel, "plain_view"));
                    break;
                case DropdownItems.Html:
                    append_to_popover_box (create_model_button (PrettifiedLabel, "prettified_view"));
                    append_to_popover_box (create_model_button (PlainLabel, "plain_view"));
                    break;
                default:
                    append_to_popover_box (create_model_button (PlainLabel, "plain_view"));
                    break;
            }
        }

        private Gtk.ModelButton create_model_button (string text_label, string view) {
            var model_button = new Gtk.ModelButton ();
            model_button.label = text_label;
            model_button.clicked.connect (() => {
                label.label = text_label;
                this.stack.set_visible_child_name (view);
            });
            return model_button;
        }

        private void append_to_popover_box (Gtk.ModelButton button) {
            popover_box.pack_start(button, false, false, 1);
        }

        public void dropdown () {
            popover.show_all ();
            popover.popup ();
        }
    }
}
