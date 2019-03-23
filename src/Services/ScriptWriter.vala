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
    }

    public class StdoutWriter : ScriptWriter, Object {
        public void write (string str) {
            stdout.printf (str + "\n");
        }
    }

    public class TextBufferWriter : ScriptWriter, Object {
        private Gtk.TextBuffer buffer;

        public TextBufferWriter (Gtk.TextBuffer b) {
            buffer = b;
        }

        public void write (string str) {
            var parts = str.split ("\n");
            if (parts.length > 1) {
                buffer.text += ">> %s\n".printf(parts[0]);
                var builder = new StringBuilder ();
                for (int i = 1; i < parts.length; i++) {
                    builder.append ("   %s\n".printf (parts[i]));
                }
                buffer.text += builder.str;
            } else {
                   buffer.text += ">> %s\n".printf(str);
            }
        }
    }
}
