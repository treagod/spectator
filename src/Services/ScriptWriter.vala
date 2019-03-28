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

namespace Spectator.Services {
    public interface ScriptWriter : Object {
        public abstract void write (string str);
        public abstract void error (string str);
    }

    public class StdoutWriter : ScriptWriter, Object {
        public void write (string str) {
            stdout.printf (str + "\n");
        }

        public void error (string str) {
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

        public void error (string err) {
            Gtk.TextIter iter;
            buffer.get_end_iter (out iter);
            var text = "<span color='red'>&gt;&gt; %s</span>\n".printf (err);
            buffer.insert_markup (ref iter, text, text.length);
        }
    }
}
