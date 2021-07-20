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

namespace Spectator.Widgets.Request {
    public class Popover : Gtk.Popover {
        private Gdk.Rectangle r;
        private Gtk.Box popover_box;
        private weak Repository.IEnvironment environments;
        private weak Gtk.Entry entry;
        private Gtk.Box no_variable_message;

        public signal void variable_selected (string name);

        public Popover (Gtk.Entry relative, Repository.IEnvironment envs) {
            relative_to = relative;
            position = Gtk.PositionType.BOTTOM;
            entry = relative;
            environments = envs;
            popover_box = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
            popover_box.margin = 3;

            closed.connect (() => {
                foreach (var child in popover_box.get_children ()) {
                    popover_box.remove (child);
                }
            });

            init_no_variable_message ();
            add (popover_box);
        }

        public void show_variables () {
            calculate_position (
                out r,
                entry.get_layout (),
                entry.text_index_to_layout_index (entry.cursor_position)
            );
            set_pointing_to (r);

            var current_environment = environments.get_current_environment ();

            var variables_exists = false;

            foreach (var variable in environments.get_environment_variables (current_environment.name)) {
                variables_exists = true;
                var button = new Gtk.ModelButton ();
                button.label = variable.key;
                button.clicked.connect (() => {
                    variable_selected (variable.key);
                });
                popover_box.add (button);
            }

            if (!variables_exists) {
                popover_box.add (no_variable_message);
            }

            show_all ();
            popup ();
        }

        private void calculate_position (out Gdk.Rectangle rectangle, Pango.Layout layout, int cursor_position) {
            var rec = layout.index_to_pos (cursor_position + 1);
            rectangle = Gdk.Rectangle ();
            rectangle.height = 20;
            rectangle.width = rec.width / Pango.SCALE;
            rectangle.x = (rec.x / Pango.SCALE);
            rectangle.y = 0;
        }

        private void init_no_variable_message () {
            no_variable_message = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
            no_variable_message.margin = 10;
            var l = new Gtk.Label ("<i>No variables in current environment defined</i>");
            l.use_markup = true;
            no_variable_message.add (l);
        }
    }
}