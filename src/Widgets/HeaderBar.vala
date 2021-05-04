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

namespace Spectator.Widgets {
    public class HeaderBar : Hdy.HeaderBar  {
        private Gtk.Button _new_request;
        private Gtk.Button _new_collection;
        public Gtk.MenuButton app_menu;

        public Gtk.Button new_request {
            get { return _new_request; }
        }

        public Gtk.Button new_collection {
            get { return _new_collection; }
        }

        public signal void preference_clicked ();
        public signal void environments_clicked ();

        public HeaderBar () {
            Object (
                has_subtitle: true,
                show_close_button: true
            );
        }

        construct {
            _new_request = new Gtk.Button.from_icon_name ("bookmark-new", Gtk.IconSize.LARGE_TOOLBAR);
            _new_request.tooltip_text = _("Create Request");

            _new_collection = new Gtk.Button.from_icon_name ("folder-new", Gtk.IconSize.LARGE_TOOLBAR);
            _new_collection.tooltip_text = _("Create Collection");

            var preference_dialog_button = new Gtk.ModelButton ();
            preference_dialog_button.text = _("Preferences");
            preference_dialog_button.show_all ();

            var environment_dialog_button = new Gtk.ModelButton ();
            environment_dialog_button.text = _("Environments");
            environment_dialog_button.show_all ();

            var menu_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 2);

            menu_box.add (preference_dialog_button);
            menu_box.add (environment_dialog_button);
            menu_box.show_all ();

            var menu = new Gtk.Popover (null);
            menu.add (menu_box);

            var app_menu = new Gtk.MenuButton ();
            app_menu.image = new Gtk.Image.from_icon_name ("open-menu", Gtk.IconSize.LARGE_TOOLBAR);
            app_menu.tooltip_text = _("Menu");
            app_menu.popover = menu;
            app_menu.show_all ();

            preference_dialog_button.clicked.connect (() => {
                preference_clicked ();
            });

            environment_dialog_button.clicked.connect (() => {
                environments_clicked ();
            });

            title = Constants.RELEASE_NAME;
            subtitle = "";
            pack_start (_new_request);
            pack_start (_new_collection);
            pack_end (app_menu);
        }
    }
}
