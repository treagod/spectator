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

namespace HTTPInspector {
    public class Window : Gtk.ApplicationWindow {
        RequestHistory request_history;

        public Window (Gtk.Application app) {
            // Store the main app to be used
            Object (application: app);

            // Theme color
            Gtk.Settings.get_default ().gtk_application_prefer_dark_theme = false;

            // Show the app
            show_app ();
        }

        public void show_app () {
            var grid = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
            grid.width_request = 950;
            grid.height_request = 500;

            var headerbar = new HeaderBar ();
            headerbar.new_request.clicked.connect (() => {
                create_request ();
            });
            set_titlebar (headerbar);

            var seperator = new Gtk.Separator (Gtk.Orientation.VERTICAL);
            seperator.visible = true;
            seperator.no_show_all = false;

            var content = new Content ();
            request_history = new RequestHistory ();

            content.welcome_activated.connect ((index) => {
                create_request ();
            });

            content.item_changed.connect ((item) => {
                request_history.update_active (item);
            });

            request_history.selection_changed.connect ((item) => {
                headerbar.subtitle = item.name;
                content.show_request_view (item);
            });

            grid.add (request_history);
            grid.add (seperator);

            grid.add (content);

            add (grid);
            show_all ();
            show ();
            present ();
        }

        private void create_request () {
            var dialog = new RequestDialog (this);
            dialog.show_all ();
            dialog.creation.connect ((item) => {
                request_history.add_request (item);
            });
        }
    }
}
