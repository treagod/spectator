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

namespace Spectator.Dialogs {
    public class EnvironmentVariables : Gtk.Box {
        private weak Repository.IEnvironment environments;
        private Gtk.Label no_variables_defined;
        private Gtk.Label no_such_environment;

        construct {
            orientation = Gtk.Orientation.VERTICAL;
            margin = 1;
            halign = Gtk.Align.CENTER;
        }

        public EnvironmentVariables(Repository.IEnvironment env) {
            environments = env;
            no_variables_defined = new Gtk.Label (_("No variables defined yet"));
            no_such_environment = new Gtk.Label (_("No such environment"));
        }

        private void clear () {
            this.foreach ((w) => {
                remove (w);
            });
        }

        public void show_environment_variables (string env_name) {
            clear ();
            
            var env = environments.get_environment_by_name (env_name);

            if (env != null) {
                if (env.get_variable_names ().is_empty) {
                    // Todo: Make singleton
                    add (no_variables_defined);
                } else {
                    foreach (var variable in env.get_variable_names ()) {
                        var box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 3);
                        var variable_name_entry = new Gtk.Entry ();
                        variable_name_entry.text = variable;
                        var variable_value_entry = new Gtk.Entry();
                        variable_value_entry.text =  env.get_variable (variable);
                        box.add (variable_name_entry);
                        box.add (variable_value_entry);
                        add (box);
                    }
                }
            } else {
                add (no_such_environment);
            }

            show_all ();
        }
    }
}
