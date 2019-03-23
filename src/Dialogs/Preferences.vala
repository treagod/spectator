/*
* Copyright (c) 2019 Marvin Ahlgrimm (https://github.com/treagod)
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
    public class Preferences : Gtk.Dialog {

        public Preferences (Gtk.Window? parent) {
            title = _("Preferences");
            border_width = 5;
            deletable = false;
            resizable = false;
            transient_for = parent;
            modal = true;

            var main_stack = new Gtk.Stack ();
            main_stack.margin = 6;
            main_stack.margin_bottom = 18;
            main_stack.margin_top = 24;
            main_stack.add_titled (new Preference.General (), "general", _("General"));
            main_stack.add_titled (new Preference.Network (), "network", _("Network"));

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
    }
}
