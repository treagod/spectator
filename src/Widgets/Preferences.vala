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

namespace HTTPInspector.Widgets {
    public class Preferences : Gtk.Dialog {

        public Preferences (Gtk.Window? parent) {
            title = _("Preferences");
            border_width = 5;
            deletable = false;
            resizable = false;
            transient_for =  parent;
            modal = true;

            var main_stack = new Gtk.Stack ();
            main_stack.margin = 6;
            main_stack.margin_bottom = 18;
            main_stack.margin_top = 24;
            main_stack.add_titled (create_general_tab (), "general", _("General"));
            main_stack.add_titled (create_network_tab (), "network", _("Network"));
            main_stack.add_titled (create_plugin_tab (), "plugins", _("Plugins"));

            var main_stackswitcher = new Gtk.StackSwitcher ();
            main_stackswitcher.set_stack (main_stack);
            main_stackswitcher.halign = Gtk.Align.CENTER;



            add_button (_("Close"), Gtk.ResponseType.CLOSE);

            response.connect ((source, id) => {
                destroy ();
            });

            var content = get_content_area () as Gtk.Box;

            content.add (main_stackswitcher);
            content.add (main_stack);

            content.margin = 15;
            content.margin_top = 0;
        }

        private Gtk.Box create_general_tab () {
            var box = new Gtk.Box (Gtk.Orientation.VERTICAL, 5);
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

            box.add (option_grid);

            return box;
        }

        private Gtk.Box create_network_tab () {
            var box = new Gtk.Box (Gtk.Orientation.VERTICAL, 5);
            var option_grid = new Gtk.Grid ();
            var settings = Settings.get_instance ();

            option_grid.column_spacing = 12;
            option_grid.row_spacing = 6;

            var use_proxy_label = new Gtk.Label(_("Use Proxy"));
            use_proxy_label.halign = Gtk.Align.START;
            var use_proxy_switch = new Gtk.Switch ();
            use_proxy_switch.halign = Gtk.Align.END;

            use_proxy_switch.active = settings.use_proxy;
            use_proxy_switch.notify.connect (() => {
                settings.use_proxy = use_proxy_switch.active;
            });

            var proxy_label = new Gtk.Label (_("HTTP Proxy"));
            proxy_label.halign = Gtk.Align.START;
            var proxy_entry = new Gtk.Entry ();
            proxy_entry.halign = Gtk.Align.END;
            proxy_entry.text = settings.http_proxy;

            proxy_entry.changed.connect (() => {
                settings.https_proxy = proxy_entry.text;
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

            option_grid.attach (use_proxy_label, 0, 0, 1, 1);
            option_grid.attach (use_proxy_switch, 1, 0, 1, 1);
            option_grid.attach (proxy_label, 0, 1, 1, 1);
            option_grid.attach (proxy_entry, 1, 1, 1, 1);
            option_grid.attach (https_proxy_label, 0, 2, 1, 1);
            option_grid.attach (https_proxy_entry, 1, 2, 1, 1);
            option_grid.attach (no_proxy_label, 0, 3, 1, 1);
            option_grid.attach (no_proxy_entry, 1, 3, 1, 1);

            option_grid.hexpand = true;

            box.add (option_grid);

            return box;
        }

        private Gtk.Box create_plugin_tab () {
            var box = new Gtk.Box (Gtk.Orientation.VERTICAL, 5);
            var option_grid = new Gtk.Grid ();
            var settings = Settings.get_instance ();

            option_grid.column_spacing = 12;
            option_grid.row_spacing = 6;

            var enable_plugins_label = new Gtk.Label(_("Enable Plugins"));
            enable_plugins_label.halign = Gtk.Align.START;
            var enable_plugins_switch = new Gtk.Switch ();
            enable_plugins_switch.halign = Gtk.Align.END;

            var plugin_folder_label = new Gtk.Label (_("Plugin Folder"));
            plugin_folder_label.halign = Gtk.Align.START;
            var plugin_folder_entry = new Gtk.Entry ();
            plugin_folder_entry.halign = Gtk.Align.END;
            plugin_folder_entry.set_icon_from_icon_name (Gtk.EntryIconPosition.SECONDARY, "folder");
            plugin_folder_entry.hexpand = true;

            plugin_folder_entry.icon_press.connect ((pos, event) => {
                if (pos == Gtk.EntryIconPosition.SECONDARY) {
                }
            });

            option_grid.attach (enable_plugins_label, 0, 0, 1, 1);
            option_grid.attach (enable_plugins_switch, 1, 0, 1, 1);
            option_grid.attach (plugin_folder_label, 0, 1, 1, 1);
            option_grid.attach (plugin_folder_entry, 1, 1, 1, 1);

            option_grid.hexpand = true;

            box.add (option_grid);

            return box;
        }
    }
}
