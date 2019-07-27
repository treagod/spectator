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
            scheme_label.valign = Gtk.Align.START;

            var fbox = new Gtk.FlowBox ();
            fbox.max_children_per_line = 1;
            fbox.column_spacing = 0;

            var ra_box = create_radio_button_box ();

            option_grid.attach (use_default_font_label, 0, 0, 1, 1);
            option_grid.attach (use_default_font_switch, 1, 0, 1, 1);
            option_grid.attach (font_label, 0, 1, 1, 1);
            option_grid.attach (font_button, 1, 1, 1, 1);
            option_grid.attach (scheme_label, 0, 2, 1, 1);
            option_grid.attach (ra_box, 1, 2, 1, 1);

            add (option_grid);
        }

        private Gtk.Box create_radio_button_box () {
            var settings = Settings.get_instance ();
            var scheme_manager = Gtk.SourceStyleSchemeManager.get_default ();
            var ra_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
            ra_box.get_style_context ().add_class ("theme-selection");
            Gtk.RadioButton radio_button = null;

            var editor_scheme = settings.editor_scheme;
            foreach (var id in scheme_manager.scheme_ids) {
                var label = create_label_for_id (id);

                if (radio_button == null) {
                    radio_button = new Gtk.RadioButton.with_label (null, label);
                } else {
                    radio_button = new Gtk.RadioButton.with_label_from_widget (radio_button, label);
                }

                radio_button.hide ();

                ra_box.pack_start (radio_button);
                radio_button.clicked.connect (() => {
                    settings.editor_scheme = id;
                    settings.editor_scheme_changed ();
                });

                if (id == editor_scheme) {
                    radio_button.active = true;
                }
            }

            return ra_box;
        }

        private string create_label_for_id (string id) {
            var part_ids = id.split ("-");
            var builder = new StringBuilder ();

            foreach (var part in part_ids) {
                part = "%s%s ".printf (part.up (1), part.substring (1));
                builder.append (part);
            }

            return builder.str;
        }
    }
}