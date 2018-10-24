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

namespace HTTPInspector.Dialogs {
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
            main_stack.add_titled (new Preference.General (), "general", _("General"));
            main_stack.add_titled (new Preference.Network (), "network", _("Network"));
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
