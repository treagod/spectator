/*
* Copyright (c) 2021 Marvin Ahlgrimm (https://github.com/treagod)
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

namespace Spectator.Widgets.Request.Scripting {
    private class BufferContent {
        public Services.ConsoleMessageType message_type { get; private set; }
        public string content { get; private set; }

        public BufferContent (string content, Services.ConsoleMessageType mt) {
            this.content = content;
            this.message_type = mt;
        }
    }
    class Container : Gtk.Box {
        private ScriptingSourceView scripting_view;
        private Gtk.TextView console;
        private uint active_id;
        private Gee.HashMap<uint, Gee.ArrayList<BufferContent>> buffers;
        private Gtk.ScrolledWindow scrolled_console;
        private Gtk.TextBuffer console_buffer {
            get {
                return console.buffer;
            }
            set {
                console.buffer = value;
            }
        }

        public signal void console_out ();
        public signal void script_changed (string script);

        public Container () {
            buffers = new Gee.HashMap<uint, Gee.ArrayList<BufferContent>> ();
            orientation = Gtk.Orientation.VERTICAL;
            spacing = 5;
            scripting_view = new ScriptingSourceView ();

            scripting_view.changed.connect ((script) => {
                script_changed (script);
            });

            var paned = new Gtk.Paned (Gtk.Orientation.VERTICAL);
            get_style_context ().add_class ("console-box");

            var button_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 1);
            var js_console_button = new Gtk.Button.from_icon_name ("utilities-terminal", Gtk.IconSize.LARGE_TOOLBAR);
            js_console_button.tooltip_text = _("JavaScript Console");
            var js_info_button = new Gtk.Button.from_icon_name ("dialog-information", Gtk.IconSize.LARGE_TOOLBAR);
            js_info_button.tooltip_text = _("JavaScript Info");

            var scrolled_scripting_view = new Gtk.ScrolledWindow (null, null);
            scrolled_console = new Gtk.ScrolledWindow (null, null);
            scrolled_console.get_style_context ().add_class ("scrolled-console");
            console = new Gtk.TextView ();
            console.wrap_mode = Gtk.WrapMode.WORD;
            console.pixels_below_lines = 3;
            console.border_width = 12;
            console.editable = false;
            console.get_style_context ().add_class (Granite.STYLE_CLASS_TERMINAL);
            var rev = new Gtk.Revealer ();


            js_console_button.clicked.connect (() => {
                if (js_console_button.relief == Gtk.ReliefStyle.NONE) {
                    rev.reveal_child = false;
                    js_console_button.relief = Gtk.ReliefStyle.NORMAL;
                } else {
                    rev.reveal_child = true;
                    js_console_button.relief = Gtk.ReliefStyle.NONE;
                }
            });

            js_info_button.clicked.connect (() => {
                try {
                    AppInfo.launch_default_for_uri ("https://treagod.github.io/spectator/docs/scripting", null);
                } catch (Error e) {
                    stderr.printf ("Could not open URL\n");
                }
            });

            scrolled_console.add (console);
            scrolled_scripting_view.add (scripting_view);
            rev.add (scrolled_console);

            paned.pack1 (scrolled_scripting_view, true, true);
            paned.pack2 (rev, true, true);
            pack_start (paned, true, true);
            button_box.pack_end (js_console_button, false, false);
            button_box.pack_end (js_info_button, false, false);
            add (button_box);
        }

        public void update_buffer (uint id, string text, Services.ConsoleMessageType mt) {
            if (!buffers.has_key (id)) {
                buffers[id] = new Gee.ArrayList<BufferContent> ();
            }

            buffers[id].add (new BufferContent (text, mt));

            if (active_id == id) {
                this.show_buffer_content (id);
            }
        }

        public void set_script_buffer (uint id) {
            if (!buffers.has_key (id)) {
                buffers[id] = new Gee.ArrayList<BufferContent> ();
            }
            active_id = id;
            this.show_buffer_content (id);
        }

        private void show_buffer_content (uint id) {
            bool first = true;
            var buffer = new Gtk.TextBuffer (null);
            foreach (var buffer_content in buffers[id]) {
                var builder = new StringBuilder ();
                if (first) {
                    first = false;
                } else {
                    builder.append_c ('\n');
                }

                Gtk.TextIter iter;
                buffer.get_end_iter (out iter);
                switch (buffer_content.message_type) {
                    case Services.ConsoleMessageType.LOG:
                        builder.append ("<span color='green'>Spectator</span> $ %s".printf (buffer_content.content));
                        var content = builder.str;
                        buffer.insert_markup (ref iter, content, content.length);
                        break;
                    case Services.ConsoleMessageType.ERROR:
                        builder.append ("<span color='red'>%s</span>".printf (buffer_content.content));
                        var content = builder.str;
                        buffer.insert_markup (ref iter, content, content.length);
                        break;
                    case Services.ConsoleMessageType.WARNING:
                        builder.append ("<span color='yellow'>%s</span>".printf (buffer_content.content));
                        var content = builder.str;
                        buffer.insert_markup (ref iter, content, content.length);
                        break;
                }
            }

            this.console.buffer = buffer;


            this.scrolled_console.size_allocate.connect (() => {
                var vadjustment = this.scrolled_console.get_vadjustment ();
                vadjustment.set_value (vadjustment.get_upper ());
            });
        }

        public void update_script_buffer (string buffer) {
            scripting_view.update_buffer (buffer);
        }
    }
}
