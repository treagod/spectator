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

namespace Spectator.Dialogs {
    public class Alert : Gtk.Dialog {
        private Gtk.Box container;
        public Alert (Gtk.Window parent, string title, string description) {
            deletable = false;
            resizable = false;
            transient_for = parent;
            modal = true;
            var content = get_content_area () as Gtk.Box;
            var message_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
            container = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 10);

            var image = new Gtk.Image ();
            image.set_from_icon_name ("dialog-warning", Gtk.IconSize.DND);
            image.no_show_all = false;
            image.show ();

            var title_label = new Gtk.Label (title);
            title_label.get_style_context ().add_class ("h1");

            add_button (_("Close"), Gtk.ResponseType.CLOSE);

            message_box.add (title_label);
            message_box.add (new Gtk.Label (description));

            container.add (image);
            container.add (message_box);

            content.margin = 15;
            content.margin_top = 0;

            response.connect ((source, id) => {
                if (id ==Gtk.ResponseType.CLOSE) {
                    destroy ();
                }
            });

            content.add (container);
        }
    }
}
