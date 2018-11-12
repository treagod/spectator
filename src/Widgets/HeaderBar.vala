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

namespace Spectator.Widgets {
    public class HeaderBar : Gtk.HeaderBar {
        private Gtk.Button _new_request;
        public Gtk.MenuButton app_menu;

        public Gtk.Button new_request {
            get { return _new_request; }
        }

        public signal void preference_clicked ();

        public HeaderBar () {
            Object (
                has_subtitle: true,
                show_close_button: true
            );
        }

        construct {
            _new_request = new Gtk.Button.from_icon_name ("bookmark-new", Gtk.IconSize.LARGE_TOOLBAR);
            _new_request.tooltip_text = _("Create Request");

            var preferences_menuitem = new Gtk.ModelButton ();
            preferences_menuitem.text = _("Preferences");

            preferences_menuitem.clicked.connect (() => {
               preference_clicked ();
            });

            var about_menuitem = new Gtk.ModelButton ();
            about_menuitem.text = _("About");

            var menu_grid = new Gtk.Grid ();
            menu_grid.margin = 7;
            menu_grid.orientation = Gtk.Orientation.VERTICAL;
            menu_grid.add (about_menuitem);
            menu_grid.add (preferences_menuitem);

            menu_grid.show_all ();

            var menu = new Gtk.Popover (null);
            menu.add (menu_grid);

            app_menu = new Gtk.MenuButton ();
            app_menu.image = new Gtk.Image.from_icon_name ("open-menu", Gtk.IconSize.LARGE_TOOLBAR);
            app_menu.tooltip_text = _("Menu");
            app_menu.popover = menu;

            title = Constants.RELEASE_NAME;
            subtitle = "";
            pack_start (_new_request);
            pack_end (app_menu);
        }
    }
}
