/*
* Copyright (c) 2020 Marvin Ahlgrimm (https://github.com/treagod)
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
        private Gtk.Button _new_collection;
        public Gtk.MenuButton app_menu;

        public Gtk.Button new_request {
            get { return _new_request; }
        }

        public Gtk.Button new_collection {
            get { return _new_collection; }
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

            _new_collection = new Gtk.Button.from_icon_name ("folder-new", Gtk.IconSize.LARGE_TOOLBAR);
            _new_collection.tooltip_text = _("Create Collection");

            var preference_button = new Gtk.Button.from_icon_name ("open-menu", Gtk.IconSize.LARGE_TOOLBAR);
            preference_button.tooltip_text = _("Preferences");

            preference_button.clicked.connect (() => {
                preference_clicked ();
            });

            title = Constants.RELEASE_NAME;
            subtitle = "";
            pack_start (_new_request);
            pack_start (_new_collection);
            pack_end (preference_button);
        }
    }
}
