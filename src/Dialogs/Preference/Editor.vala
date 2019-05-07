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

namespace Spectator.Dialogs.Preference {
    public class Editor : Gtk.Box {
        construct {
            orientation = Gtk.Orientation.VERTICAL;
            margin = 5;
        }

        public Editor () {
            var option_grid = new Gtk.Grid ();
            var settings = Settings.get_instance ();

            var font_label = new Gtk.Label (_("Font"));
            font_label.halign = Gtk.Align.START;
            var font_button = new Gtk.FontButton ();
            font_button.font = settings.font;
            font_button.font_set.connect (() => {
                settings.font = font_button.font;
                settings.font_changed ();
            });

            var use_default_font_label = new Gtk.Label (_("Use Default Font"));
            use_default_font_label.halign = Gtk.Align.START;
            var use_default_font_switch = new Gtk.Switch ();
            use_default_font_switch.halign = Gtk.Align.END;
            use_default_font_switch.active = settings.use_default_font;
            use_default_font_switch.notify.connect (() => {
                if (use_default_font_switch.active) {
                    settings.default_font ();
                } else {
                    settings.font_changed ();
                }
                font_button.sensitive = !use_default_font_switch.active;
                settings.use_default_font = use_default_font_switch.active;
            });


            option_grid.column_spacing = 12;
            option_grid.row_spacing = 6;

            var scheme_label = new Gtk.Label (_("Color Scheme"));
            scheme_label.halign = Gtk.Align.START;

            var fbox = new Gtk.FlowBox ();
            fbox.max_children_per_line = 1;
            fbox.column_spacing = 0;

            var s = Gtk.SourceStyleSchemeManager.get_default ();

            foreach (var id in s.scheme_ids) {
                var but = new Gtk.Button ();
                var r = new Gtk.Label (id);
                but.add (r);
                but.clicked.connect (() => {
                    settings.editor_scheme = r.label;
                    settings.editor_scheme_changed ();
                });
                r.halign = Gtk.Align.START;
                fbox.add (but);
            }

            option_grid.attach (use_default_font_label, 0, 0, 1, 1);
            option_grid.attach (use_default_font_switch, 1, 0, 1, 1);
            option_grid.attach (font_label, 0, 1, 1, 1);
            option_grid.attach (font_button, 1, 1, 1, 1);
            option_grid.attach (scheme_label, 0, 2, 1, 1);
            option_grid.attach (fbox, 1, 3, 1, 1);

            add (option_grid);
        }
    }
}