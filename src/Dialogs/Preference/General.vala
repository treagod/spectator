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

namespace Spectator.Dialogs.Preference {
    public class General : Gtk.Box {
        construct {
            orientation = Gtk.Orientation.VERTICAL;
            margin = 5;
        }

        public General () {
            var option_grid = new Gtk.Grid ();
            var settings = Settings.get_instance ();

            option_grid.column_spacing = 12;
            option_grid.row_spacing = 6;


            var theme_label = new Gtk.Label (_("Dark Theme"));
            theme_label.halign = Gtk.Align.START;
            var dark_theme_switch = new Gtk.Switch ();
            dark_theme_switch.halign = Gtk.Align.END;

            var redirect_label = new Gtk.Label (_("Follow redirects automatically"));
            redirect_label.halign = Gtk.Align.START;
            var redirect_switch = new Gtk.Switch ();
            redirect_switch.halign = Gtk.Align.END;

            dark_theme_switch.active = Gtk.Settings.get_default ().gtk_application_prefer_dark_theme;

            dark_theme_switch.notify.connect (() => {
                Gtk.Settings.get_default ().gtk_application_prefer_dark_theme = dark_theme_switch.active;
                settings.theme_changed ();
            });

            redirect_switch.active = settings.follow_redirects;
            redirect_switch.notify.connect (() => {
                settings.follow_redirects = redirect_switch.active;
            });

            settings.schema.bind ("dark-theme", dark_theme_switch, "active", SettingsBindFlags.DEFAULT);

            var maximum_redirects_label = new Gtk.Label (_("Maximum Redirects"));
            maximum_redirects_label.halign = Gtk.Align.START;
            var maximum_redirects_entry = new Gtk.SpinButton.with_range (0.0, 60.0, 1.0);
            maximum_redirects_entry.halign = Gtk.Align.END;
            maximum_redirects_entry.xalign = 1.0f;
            maximum_redirects_entry.value = settings.maximum_redirects;

            maximum_redirects_entry.changed.connect (() => {
                settings.maximum_redirects = maximum_redirects_entry.get_value_as_int ();
            });

            var timeout_label = new Gtk.Label (_("Network Request Timeout"));
            timeout_label.halign = Gtk.Align.START;
            var timeout_entry = new Gtk.SpinButton.with_range (0.0, 60.0, 1.0);
            timeout_entry.halign = Gtk.Align.END;
            timeout_entry.xalign = 1.0f;
            timeout_entry.value = settings.timeout;

            timeout_entry.changed.connect (() => {
                settings.timeout = timeout_entry.value;
            });

            option_grid.attach (theme_label, 0, 1, 1, 1);
            option_grid.attach (dark_theme_switch, 1, 1, 1, 1);
            option_grid.attach (redirect_label, 0, 2, 1, 1);
            option_grid.attach (redirect_switch, 1, 2, 1, 1);
            option_grid.attach (maximum_redirects_label, 0, 3, 1, 1);
            option_grid.attach (maximum_redirects_entry, 1, 3, 1, 1);
            option_grid.attach (timeout_label, 0, 4, 1, 1);
            option_grid.attach (timeout_entry, 1, 4, 1, 1);

            add (option_grid);
        }
    }
}
