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

namespace HTTPInspector.Widgets.Request {
    class BodyView : Gtk.Box {
        public BodyView () {
            var grid = new Gtk.Grid ();
            var box = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
            var label = new UrlEntry ();
            box.add (label);
            var method_box = new Gtk.ComboBoxText ();
            method_box.append_text ("form-data");
            method_box.append_text ("x-www-form-urlencoded");
            method_box.append_text ("raw");
            method_box.halign = Gtk.Align.END;
            method_box.active = 0;

            grid.attach (method_box, 1, 0, 1, 1);
            grid.attach (box, 0, 1, 2, 1);


            add (grid);
        }
    }
}