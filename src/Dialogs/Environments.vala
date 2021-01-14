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
    public class EnvironmentRow : Gtk.ListBoxRow {
        public string env_name;
        
        public EnvironmentRow (string n) {
            env_name = n;
            var label = new Gtk.Label(env_name);
            label.halign = Gtk.Align.START;
            add (label);
        }
    }
    public class Environments : Gtk.Dialog {
        public Gtk.ListBox environment_list;
        private EnvironmentVariables environment_variables;

        construct {
            use_header_bar = 1;
        }

        public Environments (Window parent) {
            title = _("Environments");
            border_width = 5;
            deletable = false;
            resizable = false;
            transient_for = parent;
            modal = true;

            add_button (_("Close"), Gtk.ResponseType.CLOSE);
            response.connect ((source, id) => {
                destroy ();
            });

            build_headerbar (parent.environment_service);
            build_content (parent.environment_service);
        }

        private void build_headerbar (Repository.IEnvironment repository) {
            var headerbar = get_header_bar ();
            var new_environment = new Gtk.Button.from_icon_name ("bookmark-new", Gtk.IconSize.LARGE_TOOLBAR);
            new_environment.tooltip_text = _("Create Environment");
            new_environment.clicked.connect (() => {
                var dialog = new NewEnvironment ((Window) this.transient_for);
                dialog.environemnt_created.connect (() => {
                    environment_list.foreach((w) => {
                        environment_list.remove (w);
                    });

                    foreach (var env in repository.get_environments ()) {
                        environment_list.add (new EnvironmentRow (env.name));
                    }
                    environment_list.show_all ();
                });
                dialog.show_all ();
            });
            headerbar.pack_start (new_environment);
        }

        private void build_content (Repository.IEnvironment environment_repository) {
            var content = get_content_area () as Gtk.Box;
            var paned = new Gtk.Paned (Gtk.Orientation.HORIZONTAL);
            
            environment_list = new Gtk.ListBox ();
            environment_variables = new EnvironmentVariables (environment_repository);
            environment_list.selection_mode = Gtk.SelectionMode.SINGLE;

            foreach (var env in environment_repository.get_environments ()) {
                environment_list.add (new EnvironmentRow (env.name));
            }

            environment_list.row_activated.connect ((r) => {
                var env_row = (EnvironmentRow) r;
                environment_variables.show_environment_variables (env_row.env_name);
            });
            
            paned.pack1 (environment_list, false, true);
            paned.pack2 (environment_variables, true, false);

            var current_env = environment_repository.get_current_environment ();
            
            // Select row
            environment_list.foreach((w) => {
                var row = (EnvironmentRow) w;

                if (row.env_name == current_env.name) {
                    environment_list.select_row (row);

                    environment_variables.show_environment_variables (row.env_name);
                    return;
                }
            });

            content.width_request = 675;
            content.height_request = 460;

            content.add (paned);
            content.show_all ();
        }
    }
}
