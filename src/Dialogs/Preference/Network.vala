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
    public class Network : Gtk.Box {
        construct {
            orientation = Gtk.Orientation.VERTICAL;
            margin = 5;
        }

        public Network () {
            var option_grid = new Gtk.Grid ();
            var settings = Settings.get_instance ();

            option_grid.column_spacing = 12;
            option_grid.row_spacing = 6;

            var use_proxy_label = new Gtk.Label (_("Use Proxy"));
            use_proxy_label.halign = Gtk.Align.START;
            var use_proxy_switch = new Gtk.Switch ();
            use_proxy_switch.halign = Gtk.Align.END;

            use_proxy_switch.active = settings.use_proxy;


            var proxy_label = new Gtk.Label (_("HTTP Proxy"));
            proxy_label.halign = Gtk.Align.START;
            var proxy_entry = new Gtk.Entry ();
            proxy_entry.halign = Gtk.Align.END;
            proxy_entry.text = settings.http_proxy;

            proxy_entry.changed.connect (() => {
                settings.http_proxy = proxy_entry.text;
            });

            var https_proxy_label = new Gtk.Label (_("HTTPS Proxy"));
            https_proxy_label.halign = Gtk.Align.START;
            var https_proxy_entry = new Gtk.Entry ();
            https_proxy_entry.halign = Gtk.Align.END;
            https_proxy_entry.text = settings.https_proxy;

            https_proxy_entry.changed.connect (() => {
                settings.https_proxy = https_proxy_entry.text;
            });

            var no_proxy_label = new Gtk.Label (_("No Proxy"));
            no_proxy_label.halign = Gtk.Align.START;
            var no_proxy_entry = new Gtk.Entry ();
            no_proxy_entry.halign = Gtk.Align.END;
            no_proxy_entry.text = settings.no_proxy;
            no_proxy_entry.hexpand = true;

            no_proxy_entry.changed.connect (() => {
                settings.no_proxy = no_proxy_entry.text;
            });

            var user_information_label = new Gtk.Label (_("Use User Information"));
            user_information_label.halign = Gtk.Align.START;
            var user_information_switch = new Gtk.Switch ();
            user_information_switch.halign = Gtk.Align.END;
            user_information_switch.active = settings.use_userinformation;

            var username_label = new Gtk.Label (_("Username"));
            username_label.halign = Gtk.Align.START;
            var username_entry = new Gtk.Entry ();
            username_entry.halign = Gtk.Align.END;
            username_entry.text = settings.proxy_username;
            username_entry.hexpand = true;

            username_entry.changed.connect (() => {
                settings.proxy_username = username_entry.text;
            });


            var password_label = new Gtk.Label (_("Password"));
            password_label.halign = Gtk.Align.START;
            var password_entry = new Gtk.Entry ();
            password_entry.halign = Gtk.Align.END;
            password_entry.text = settings.proxy_password;
            password_entry.hexpand = true;
            password_entry.visibility = false;
            password_entry.secondary_icon_name = "channel-secure-symbolic";
            password_entry.secondary_icon_activatable = true;
            password_entry.icon_press.connect ((pos, event) => {
                if (password_entry.visibility) {
                    password_entry.visibility = false;
                    password_entry.secondary_icon_name = "channel-secure-symbolic";
                } else {
                    password_entry.visibility = true;
                    password_entry.set_icon_from_icon_name (Gtk.EntryIconPosition.SECONDARY,
                                                            "channel-insecure-symbolic");
                }
            });


            password_entry.changed.connect (() => {
                settings.proxy_password = password_entry.text;
            });

            user_information_switch.state_set.connect (() => {
                var use_userinformation = user_information_switch.active;
                settings.use_userinformation = use_userinformation;
                username_entry.sensitive = use_userinformation;
                password_entry.sensitive = use_userinformation;
                return true;
            });

            username_entry.sensitive = user_information_switch.active;
            password_entry.sensitive = user_information_switch.active;

            var use_prox = settings.use_proxy;
            proxy_entry.sensitive = use_prox;
            https_proxy_entry.sensitive = use_prox;
            no_proxy_entry.sensitive = use_prox;
            user_information_switch.sensitive = use_prox;
            username_entry.sensitive = use_prox;
            password_entry.sensitive = use_prox;

            use_proxy_switch.active = settings.use_proxy;

            option_grid.attach (use_proxy_label, 0, 0, 1, 1);
            option_grid.attach (use_proxy_switch, 1, 0, 1, 1);
            option_grid.attach (proxy_label, 0, 1, 1, 1);
            option_grid.attach (proxy_entry, 1, 1, 1, 1);
            option_grid.attach (https_proxy_label, 0, 2, 1, 1);
            option_grid.attach (https_proxy_entry, 1, 2, 1, 1);
            option_grid.attach (no_proxy_label, 0, 3, 1, 1);
            option_grid.attach (no_proxy_entry, 1, 3, 1, 1);
            option_grid.attach (user_information_label, 0, 4, 1, 1);
            option_grid.attach (user_information_switch, 1, 4, 1, 1);
            option_grid.attach (username_label, 0, 5, 1, 1);
            option_grid.attach (username_entry, 1, 5, 1, 1);
            option_grid.attach (password_label, 0, 6, 1, 1);
            option_grid.attach (password_entry, 1, 6, 1, 1);

            option_grid.hexpand = true;

            use_proxy_switch.state_set.connect (() => {
                var use_proxy = use_proxy_switch.active;
                settings.use_proxy = use_proxy;
                proxy_entry.sensitive = use_proxy;
                https_proxy_entry.sensitive = use_proxy;
                no_proxy_entry.sensitive = use_proxy;
                user_information_switch.sensitive = use_proxy;
                username_entry.sensitive = user_information_switch.active && use_proxy;
                password_entry.sensitive = user_information_switch.active && use_proxy;
                return true;
            });

            add (option_grid);
        }
    }
}
