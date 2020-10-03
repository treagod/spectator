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

namespace Spectator.Widgets.Request {
    public class BodySourceView : Gtk.SourceView {
        private new Gtk.SourceBuffer buffer;
        private Gtk.SourceLanguageManager manager;
        private uint timeout_id;
        public bool buffer_updated { get; private set; }
        public Gtk.SourceStyleSchemeManager style_scheme_manager;

        // Not optimal as every single keystroke invokes this signal.
        // Better would be a strategy which sends only chunks of the buffer
        public signal void body_buffer_changed (string content);

        public BodySourceView () {
            Object (
                highlight_current_line: false,
                show_right_margin: false,
                wrap_mode: Gtk.WrapMode.WORD_CHAR
            );

            this.timeout_id = 0;
            this.buffer_updated = true;
        }

        public void set_lang (string lang) {
            buffer.language = manager.get_language (lang);
        }

        public void set_content (string content) {
            buffer.text = content;
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

            buffer.language = manager.get_language ("plain");
            buffer.end_user_action.connect (() => {
                this.buffer_updated = false;
                // Clear timeout if the user is already typing
                if (timeout_id > 0) {
                    Source.remove (timeout_id);
                    timeout_id = 0;
                }

                timeout_id = Timeout.add (550, () => {
                    body_buffer_changed (buffer.text);
                    timeout_id = 0;
                    this.buffer_updated = true;
                    return false;
                });
            });
            auto_indent = true;
        }

        public void insert (string text) {
            try {
               buffer.text = convert_with_fallback (text, text.length, "UTF-8", "ISO-8859-1");
           } catch (ConvertError e) {
               stderr.printf ("Error converting markup for" + text + ", "+ e.message);
           }
        }
    }
}
