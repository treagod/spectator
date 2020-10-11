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

namespace Spectator.Widgets.Response {
    class SourceView : Gtk.SourceView {
        public new Gtk.SourceBuffer buffer;
        public Gtk.SourceLanguageManager manager;
        public Gtk.SourceStyleSchemeManager style_scheme_manager;

        private Gtk.SourceLanguage? language {
            set {
                buffer.language = value;
            }
        }

        public void set_lang (string lang) {
            language = manager.get_language (lang);
        }

        public SourceView () {
            Object (
                highlight_current_line: false,
                show_right_margin: false,
                wrap_mode: Gtk.WrapMode.WORD_CHAR
            );
        }

        public void insert_text (string res) {
            buffer.text = res;
        }

        public void insert (Models.Response? res) {
            if (res == null) {
                buffer.text = "";
            }

            insert_text (res.data);
        }

        private void set_default_font () {
            override_font (Pango.FontDescription.from_string (
                    new GLib.Settings ("org.gnome.desktop.interface")
                        .get_string ("monospace-font-name")));
        }

        private void set_font (string font) {
            override_font (Pango.FontDescription.from_string (font));
        }

        public void set_editor_scheme (string scheme) {
            buffer.style_scheme = style_scheme_manager.get_scheme (scheme);
        }

        construct {
            manager = Gtk.SourceLanguageManager.get_default ();
            editable = false;
            style_scheme_manager = new Gtk.SourceStyleSchemeManager ();
            var settings = Settings.get_instance ();

            settings.editor_scheme_changed.connect (() => {
                set_editor_scheme (settings.editor_scheme);
            });

            if (settings.use_default_font) {
                set_default_font ();
            } else {
                set_font (settings.font);
            }

            settings.font_changed.connect (() => {
                set_font (settings.font);
            });

            settings.default_font.connect (() => {
                set_default_font ();
            });

            buffer = new Gtk.SourceBuffer (null);
            buffer.highlight_syntax = true;
            set_editor_scheme (settings.editor_scheme);

            set_buffer (buffer);
            set_show_line_numbers (false);

            language = manager.get_language ("html");
        }
    }
}
