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
    public class UpdateEnvironment : Gtk.Dialog {
        private Gtk.Entry entry;
        private Gtk.Label warning;
        private Gtk.Box message_box;
        private string old_name;
        private weak Repository.IEnvironment environment;

        public signal void environemnt_renamed ();

        public UpdateEnvironment (Window parent, string name) {
            title = "%s %s".printf (_("Rename Environment"), name);
            border_width = 5;
            deletable = false;
            resizable = false;
            transient_for = parent;
            modal = true;
            environment = parent.environment_service;
            old_name = name;

            var box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 5);
            var label = new Gtk.Label (_("Environment Name"));
            entry = new Gtk.Entry ();
            entry.text = name;

            box.pack_start (label);
            box.pack_start (entry);

            add_button (_("Rename"), Gtk.ResponseType.APPLY);
            add_button (_("Close"), Gtk.ResponseType.CLOSE);

            entry.activate.connect (() => {
                create_environment ();
            });

            response.connect ((source, id) => {
                switch (id) {
                case Gtk.ResponseType.APPLY:
                    create_environment ();
                    break;
                case Gtk.ResponseType.CLOSE:
                    destroy ();
                    break;
                }
            });

            message_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
            var content = get_content_area () as Gtk.Box;
            content.pack_start (box);
            content.pack_start (message_box);

            content.margin = 15;
            content.margin_top = 0;
        }

        private void create_environment () {
            entry.get_style_context ().remove_class ("error");
            if (entry.text.length == 0) {
                show_error (_("Environment name must not be empty"));
                return;
            }

            if (entry.text == old_name) {
                destroy ();
                return;
            }

            try {
                environment.update_environment (old_name, entry.text);
                environemnt_renamed ();
                destroy ();
            } catch (Repository.RecordExistsError e) {
                show_error (_("Environment name already exists"));
            }
        }

        private void show_error (string warning_string) {
            message_box.foreach ((w) => {
                message_box.remove (w);
            });

            warning = new Gtk.Label ("<span color=\"#a10705\">" + warning_string + "</span>");
            warning.use_markup = true;
            warning.margin = 5;
            message_box.pack_start (warning, false, true, 0);
            show_all ();
            entry.get_style_context ().add_class ("error");
        }
    }
}
