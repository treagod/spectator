/*
* Copyright (c) 2011-2017 Marvin Ahlgrimm
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
* Authored by: Marvin Ahlgrimm
*/

namespace HTTPInspector {
    public class Window : Gtk.ApplicationWindow {

        public Window (Gtk.Application app) {
            // Store the main app to be used
            Object (application: app);
            
            // Theme color
            //Gtk.Settings.get_default ().gtk_application_prefer_dark_theme = true;	

            // Show the app
            show_app ();
        }

        public void show_app () {
            var grid = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
            grid.width_request = 950;
            grid.height_request = 500;

            var seperator = new Gtk.Separator (Gtk.Orientation.VERTICAL);
            seperator.visible = true;
            seperator.no_show_all = false;


            var request_view  = new Request ();
            var request_history = new RequestHistory ();


            grid.add (request_history);
            grid.add (seperator);
            // grid.add (request_view);
            var welcome = new Granite.Widgets.Welcome (_("HTTP Inspector"), _("Inspect your HTTP transmissions to the web"));
            welcome.hexpand = true;
            welcome.append ("bookmark-new", _("Create Request"), _("Create a new request to the web."));
            
            welcome.activated.connect((index) => {
                create_request ();
            });
            grid.add (welcome);
            
            var headerbar = new HeaderBar ();
            headerbar.new_request.clicked.connect (() => {
                create_request ();
            });
            set_titlebar (headerbar);
            

            add (grid);
            show_all ();
            show ();
            present ();
        }
        
        private void create_request () {
            var dialog = new RequestDialog (this);
            dialog.show_all ();
        }
    }
}
