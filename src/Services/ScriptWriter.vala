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

namespace Spectator.Services {
    public interface ScriptWriter : Object {
        public signal void written (string str);
        public signal void error_written (string str);
        public signal void warning_written (string str);


        public abstract void write (string str);
        public abstract void error (string str);
        public abstract void warning (string str);
    }

    public class BufferWriter : ScriptWriter, Object {
        public void write (string str) {
            written (str);
        }

        public void error (string str) {
            error_written (str);
        }

        public void warning (string str) {
            warning_written (str);
        }

    }

    public class StdoutWriter : ScriptWriter, Object {
        public void write (string str) {
            stdout.printf (str + "\n");
        }

        public void error (string str) {
            stderr.printf (str + "\n");
        }

        public void warning (string str) {
            stderr.printf (str + "\n");
        }
    }

    public class TextBufferWriter : ScriptWriter, Object {
        private unowned Gtk.TextBuffer buffer;

        public TextBufferWriter (Gtk.TextBuffer b) {
            buffer = b;
        }

        public void write (string str) {
            var parts = str.split ("\n");
            Gtk.TextIter iter;
            buffer.get_end_iter (out iter);

            if (parts.length > 1) {
                var text = "&gt;&gt; %s\n".printf (parts[0]);
                buffer.insert_markup (ref iter, text, text.length);
                for (int i = 1; i < parts.length; i++) {
                    buffer.get_end_iter (out iter);
                    var text_part = "   %s\n".printf (parts[i]);
                    buffer.insert_markup (ref iter, text_part, text_part.length);
                }
            } else {
                var text = "&gt;&gt; %s\n".printf (str);
                buffer.insert_markup (ref iter, text, text.length);
            }
        }

        private void colored_output (string text, string color) {
            Gtk.TextIter iter;
            buffer.get_end_iter (out iter);
            var colored_text = "<span color='%s'>&gt;&gt; %s</span>\n".printf (color, text);
            buffer.insert_markup (ref iter, colored_text, colored_text.length);
        }

        public void error (string err) {
            colored_output (err, "red");
        }

        public void warning (string err) {
            colored_output (err, "yellow");
        }
    }
}
