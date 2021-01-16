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
        private Gtk.Box variable_container;
        private string current_env_name;

        public signal void variable_added ();

        construct {
            orientation = Gtk.Orientation.VERTICAL;
            halign = Gtk.Align.CENTER;
            hexpand = true;
        }

        public EnvironmentVariables(Repository.IEnvironment env) {
            environments = env;
            variable_container = new Gtk.Box (Gtk.Orientation.VERTICAL, 2);
            no_variables_defined = new Gtk.Label (_("No variables defined yet"));
            no_such_environment = new Gtk.Label (_("No such environment"));
            variable_container = new Gtk.Box (Gtk.Orientation.VERTICAL, 5);
            
            var add_row_button = new Gtk.Button.with_label (_("Add variable"));

            add_row_button.get_style_context ().add_class ("add-row-btn");

            add_row_button.clicked.connect (() => {
                environments.add_variable_to_environment (current_env_name);
                show_environment_variables (current_env_name.strip ()); // Refactor.. something fishy here
            });

            add (variable_container);
            add (add_row_button);
        }

        private void clear () {
            variable_container.foreach ((w) => {
                variable_container.remove (w);
            });
        }

        public void show_environment_variables (string env_name) {
            clear ();
            current_env_name = env_name;
            
            var env = environments.get_environment_by_name (env_name);
            var env_variables = environments.get_environment_variables (env_name);

            if (env != null) {
                if (env_variables.is_empty) {
                    variable_container.add (no_variables_defined);
                } else {
                    foreach (var variable in env_variables) {
                        var box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 3);
                        var variable_name_entry = new Gtk.Entry ();
                        variable_name_entry.text = variable.key;
                        variable_name_entry.changed.connect (() => {
                            environments.update_variable_name_in_environment (env, variable.id, variable_name_entry.text);
                        });
                        var variable_value_entry = new Gtk.Entry();
                        variable_value_entry.text = variable.val;
                        variable_value_entry.changed.connect (() => {
                            environments.update_variable_value_in_environment (env, variable.id, variable_value_entry.text);
                        });
                        var del_button = new Gtk.Button.from_icon_name ("window-close");
                        del_button.clicked.connect (() => {
                            environments.delete_variable_value_in_environment (env, variable.id);
                            show_environment_variables (env_name);
                        });
                        box.pack_start (variable_name_entry);
                        box.pack_start (variable_value_entry);
                        box.add (del_button);
                        box.hexpand = true;
                        variable_container.add (box);
                    }
                }
            } else {
                variable_container.add (no_such_environment);
            }

            show_all ();
        }
    }
}
