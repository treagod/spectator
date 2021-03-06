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

        public signal void rename_environment (string name);
        public signal void duplicate_environment (string name);
        public signal void delete_environment (string name);

        public EnvironmentRow (string n) {
            env_name = n;
            var label = new Gtk.Label(env_name);
            label.halign = Gtk.Align.START;
            var event_box = new Gtk.EventBox ();
            event_box.add (label);

            event_box.button_release_event.connect((event) => {
                if (event.button == 3) {
                    var menu = new Gtk.Menu ();
                    var edit_item = new Gtk.MenuItem.with_label (_("Rename"));
                    var clone_item = new Gtk.MenuItem.with_label (_("Clone"));
                    var delete_item = new Gtk.MenuItem.with_label (_("Delete"));

                    edit_item.activate.connect (() => {
                        rename_environment (env_name);
                    });

                    clone_item.activate.connect (() => {
                        duplicate_environment (env_name);
                    });

                    delete_item.activate.connect (() => {
                        delete_environment (env_name);
                    });

                    menu.add (edit_item);
                    menu.add (clone_item);
                    menu.add (delete_item);
                    menu.show_all ();
                    menu.popup_at_pointer (event);
                }
                return true;
            });
            add (event_box);
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
            var headerbar = (Gtk.HeaderBar) get_header_bar (); // Todo: Remove type-cast with modern compiler (Odin)
            var new_environment = new Gtk.Button.from_icon_name ("bookmark-new", Gtk.IconSize.LARGE_TOOLBAR);
            new_environment.tooltip_text = _("Create Environment");
            new_environment.clicked.connect (() => {
                var dialog = new NewEnvironment ((Window) this.transient_for);
                dialog.environemnt_created.connect (() => {
                    fill_list (repository);
                    environment_list.show_all ();
                });
                dialog.show_all ();
                select_current_environment (repository);
            });
            headerbar.pack_start (new_environment);
        }

        private void select_current_environment (Repository.IEnvironment environment_repository) {
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
        }

        private void fill_list (Repository.IEnvironment environment_repository) {
            environment_list.foreach ((w) => {
                environment_list.remove (w);
            });
            foreach (var env in environment_repository.get_environments ()) {
                var new_row = new EnvironmentRow (env.name);

                new_row.delete_environment.connect ((name) => {
                    environment_repository.delete_environment (name);
                    fill_list (environment_repository);
                    environment_list.show_all ();
                    select_current_environment (environment_repository);
                });

                new_row.duplicate_environment.connect ((name) => {
                    environment_repository.duplicate_environment (name);
                    fill_list (environment_repository);
                    environment_list.show_all ();
                    select_current_environment (environment_repository);
                });
                environment_list.add (new_row);
            }
        }

        private void build_content (Repository.IEnvironment environment_repository) {
            var content = get_content_area () as Gtk.Box;
            var paned = new Gtk.Paned (Gtk.Orientation.HORIZONTAL);

            environment_list = new Gtk.ListBox ();
            environment_variables = new EnvironmentVariables (environment_repository);
            environment_list.selection_mode = Gtk.SelectionMode.SINGLE;

            fill_list (environment_repository);

            environment_list.row_activated.connect ((r) => {
                var env_row = (EnvironmentRow) r;
                environment_variables.show_environment_variables (env_row.env_name);
            });

            paned.pack1 (environment_list, false, true);
            paned.pack2 (environment_variables, true, false);

            select_current_environment (environment_repository);

            content.width_request = 670;
            content.height_request = 460;

            content.add (paned);
            content.show_all ();
        }
    }
}
