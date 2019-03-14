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
    class ScriptingView : Gtk.SourceView {
        public signal void changed (string script);
        public new Gtk.SourceBuffer buffer;
        private string font { set; get; default = "Roboto Mono Regular 11"; }
        private int64 last_key_input;

        public ScriptingView () {
            Object (
                highlight_current_line: true,
                show_right_margin: false,
                wrap_mode: Gtk.WrapMode.WORD_CHAR
            );
            show_line_numbers = true;
            var manager = Gtk.SourceLanguageManager.get_default ();
            buffer = new Gtk.SourceBuffer (null);
            buffer.highlight_syntax = true;
            indent_width = 4;
            insert_spaces_instead_of_tabs = true;
            indent_on_tab = true;
            auto_indent = true;

            buffer.language = manager.get_language ("js");
            set_buffer (buffer);

            buffer.changed.connect (() => {
                signal_change_after_delay ();
            });
        }

        private void signal_change_after_delay () {
            last_key_input = GLib.get_monotonic_time () / 1000;
            new Thread<bool> ("typing_check", () => {
                Thread.usleep (1000000);
                var time_now = GLib.get_monotonic_time () / 1000;;
                if (time_now - last_key_input >= 1000) {
                    changed (buffer.text);
                }

                return true;
            });
        }

        public void update_buffer (string code) {
            buffer.text = code;
        }
    }
}
