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
        private Gtk.Stack body_content;
        private Gtk.ComboBoxText body_type_box;
        private Gtk.ComboBoxText language_box;

        construct {
            orientation = Gtk.Orientation.VERTICAL;
            margin = 2;
        }

        public BodyView () {
            body_content = new Gtk.Stack ();
            body_content.add_named (new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0), "form-data");
            body_content.add_named (new Gtk.Label ("x-www-form-urlencoded"), "x-www-form-urlencoded");
            body_content.set_visible_child_name ("form-data");
            body_content.hexpand = true;

            setup_body_type_box ();
            setup_language_box ();
            setup_body_type_behaviour ();

            add (body_content);
        }

        private void setup_language_box () {
            language_box = new Gtk.ComboBoxText ();
            language_box.append_text ("Plain");
            language_box.append_text ("XML");
            language_box.append_text ("JSON");
            language_box.append_text ("HTML");
            language_box.active = 0;
        }

        private void setup_body_type_box () {
            body_type_box = new Gtk.ComboBoxText ();
            body_type_box.append_text ("form-data");
            body_type_box.append_text ("x-www-form-urlencoded");
            body_type_box.append_text ("raw");
            body_type_box.active = 0;
        }

        private void setup_body_type_behaviour () {
            var body_content_type_selections = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 4);
            body_content_type_selections.halign = Gtk.Align.END;

            body_type_box.changed.connect (() => {
                var index = body_type_box.get_active ();
                body_content_type_selections.remove (body_type_box);
                body_content_type_selections.remove (language_box);

                switch (index) {
                    case 0:
                    body_content_type_selections.add (body_type_box);
                    break;
                    case 1:
                    body_content_type_selections.add (body_type_box);
                    break;
                    case 2:
                    body_content_type_selections.add (language_box);
                    body_content_type_selections.add (body_type_box);
                    break;
                    default:
                    assert_not_reached ();
                }
                body_content_type_selections.show_all ();
            });

            body_content_type_selections.add (body_type_box);

            add (body_content_type_selections);
        }
    }
}
