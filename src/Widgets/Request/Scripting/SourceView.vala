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

namespace Spectator.Widgets.Request {
    class ScriptingSourceView : Gtk.SourceView {
        public signal void changed (string script);
        public new Gtk.SourceBuffer buffer;
        private uint timeout_id;
        public Gtk.SourceStyleSchemeManager style_scheme_manager;

        private void set_default_font () {
            override_font (Pango.FontDescription.from_string (
                    new GLib.Settings ("org.gnome.desktop.interface")
                        .get_string ("monospace-font-name")));
        }

        private void set_font (string font) {
            override_font (Pango.FontDescription.from_string (font));
        }

        private void set_editor_scheme (string scheme) {
            buffer.style_scheme = style_scheme_manager.get_scheme (scheme);
        }

        public ScriptingSourceView () {
            Object (
                highlight_current_line: true,
                show_right_margin: false,
                wrap_mode: Gtk.WrapMode.WORD_CHAR
            );
            show_line_numbers = true;
            var manager = Gtk.SourceLanguageManager.get_default ();
            style_scheme_manager = new Gtk.SourceStyleSchemeManager ();
            var settings = Settings.get_instance ();

            if (settings.use_default_font) {
                set_default_font ();
            } else {
                set_font (settings.font);
            }

            settings.editor_scheme_changed.connect (() => {
                set_editor_scheme (settings.editor_scheme);
            });

            settings.font_changed.connect (() => {
                set_font (settings.font);
            });

            settings.default_font.connect (() => {
                set_default_font ();
            });

            buffer = new Gtk.SourceBuffer (null);
            buffer.highlight_syntax = true;
            set_editor_scheme (settings.editor_scheme);

            indent_width = 4;
            insert_spaces_instead_of_tabs = true;
            indent_on_tab = true;
            auto_indent = true;

            buffer.language = manager.get_language ("js");
            set_buffer (buffer);

            buffer.end_user_action.connect (() => {
                // Clear timeout if the user is already typing
                if (timeout_id > 0) {
                    Source.remove (timeout_id);
                    timeout_id = 0;
                }

                timeout_id = Timeout.add (550, () => {
                    changed (buffer.text);
                    timeout_id = 0;
                    return false;
                });
            });
        }
        public void update_buffer (string code) {
            buffer.text = code;
        }
    }
}
