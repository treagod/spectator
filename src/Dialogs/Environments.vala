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
            label.margin = 7;
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
                    return true;
                }
                return false;
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
                dialog.environemnt_created.connect ((env_name) => {
                    fill_list (repository);
                    environment_list.show_all ();
                    select_environment (new Models.Environment (env_name), repository);
                });
                dialog.show_all ();
            });
            headerbar.pack_start (new_environment);
        }

        private void select_environment (Models.Environment env, Repository.IEnvironment environment_repository) {
            // Select row
            environment_list.foreach((w) => {
                var row = (EnvironmentRow) w;

                if (row.env_name == env.name) {
                    environment_list.select_row (row);

                    environment_variables.show_environment_variables (row.env_name);
                    return;
                }
            });
        }

        private void select_current_environment (Repository.IEnvironment environment_repository) {
            select_environment (environment_repository.get_current_environment (), environment_repository);
        }

        private bool confirm_deletion (string name) {
            var message_dialog = new Granite.MessageDialog.with_image_from_icon_name (
                _("Delete Environment?"),
                _("This action will permanently delete <b>%s</b>. This can't be undone!".printf (name)),
                "dialog-warning",
                Gtk.ButtonsType.CANCEL
           );
           bool confirmation = false;

           message_dialog.transient_for = this;
           message_dialog.secondary_label.use_markup = true;

           var suggested_button = new Gtk.Button.with_label (_("Delete Environment"));
           suggested_button.get_style_context ().add_class (Gtk.STYLE_CLASS_DESTRUCTIVE_ACTION);
           message_dialog.add_action_widget (suggested_button, Gtk.ResponseType.ACCEPT);

           message_dialog.show_all ();
           if (message_dialog.run () == Gtk.ResponseType.ACCEPT) {
               confirmation = true;
           }

           message_dialog.destroy ();
           return confirmation;
        }

        private void fill_list (Repository.IEnvironment environment_repository) {
            environment_list.foreach ((w) => {
                environment_list.remove (w);
            });
            foreach (var env in environment_repository.get_environments ()) {
                var new_row = new EnvironmentRow (env.name);

                new_row.rename_environment.connect((name) => {
                    var dialog = new UpdateEnvironment ((Window) this.transient_for, name);
                    dialog.environemnt_renamed.connect (() => {
                        fill_list (environment_repository);
                        environment_list.show_all ();
                    });
                    dialog.show_all ();
                });

                new_row.delete_environment.connect ((name) => {
                    if (confirm_deletion (name)) {
                        environment_repository.delete_environment (name);
                        fill_list (environment_repository);
                        environment_list.show_all ();
                        select_current_environment (environment_repository);
                    }
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
            environment_list.vexpand = true;
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
