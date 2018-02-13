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

namespace HTTPInspector {
    class HeaderField : Gtk.Box {
        public int index { get; private set; }
        private Gtk.Entry header_key_field;
        private Gtk.Entry header_value_field;

        public string key { get { return header_key_field.text; }}
        public string val { get { return header_value_field.text; }}

        public signal void header_changed (int i, string key, string val);

        construct {
            orientation = Gtk.Orientation.HORIZONTAL;
        }

        public HeaderField (int i) {
            index = i;
            header_key_field = new Gtk.Entry ();
            header_value_field = new Gtk.Entry ();

            header_value_field.focus_in_event.connect (() => {
                // Change Completion According to header key
                if (header_key_field.text == "Content-Type") {
                    header_value_field.set_completion (common_content_type_completion ());
                } else {
                    header_value_field.set_completion (null);
                }
                return false;
            });

            header_value_field.focus_out_event.connect (() => {
                header_changed (index, key, val);

                return false;
            });

            header_key_field.focus_out_event.connect (() => {
                header_changed (index, key, val);

                return false;
            });

            header_key_field.hexpand = true;
            header_value_field.hexpand = true;

            header_key_field.set_completion (common_header_key_completion ());

            add (header_key_field);
            add (header_value_field);
        }

        public void set_header (string key, string val) {
            header_key_field.text = key;
            header_value_field.text = val;
        }

        private static Gtk.EntryCompletion common_header_key_completion () {
            Gtk.EntryCompletion completion = new Gtk.EntryCompletion ();

            // Create, fill & register a ListStore:
            Gtk.ListStore list_store = new Gtk.ListStore (1, typeof (string));
            completion.set_model (list_store);
            completion.set_text_column (0);
            Gtk.TreeIter iter;

            list_store.append (out iter);
            list_store.set (iter, 0, "Accept");
            list_store.append (out iter);
            list_store.set (iter, 0, "Accept-Charset");
            list_store.append (out iter);
            list_store.set (iter, 0, "Accept-Encoding");
            list_store.append (out iter);
            list_store.set (iter, 0, "Accept-Language");
            list_store.append (out iter);
            list_store.set (iter, 0, "Authorization");
            list_store.append (out iter);
            list_store.set (iter, 0, "Cache-Control");
            list_store.append (out iter);
            list_store.set (iter, 0, "Connection");
            list_store.append (out iter);
            list_store.set (iter, 0, "Cookie");
            list_store.append (out iter);
            list_store.set (iter, 0, "Content-Length");
            list_store.append (out iter);
            list_store.set (iter, 0, "Content-MD5");
            list_store.append (out iter);
            list_store.set (iter, 0, "Content-Type");
            list_store.append (out iter);
            list_store.set (iter, 0, "Date");
            list_store.append (out iter);
            list_store.set (iter, 0, "Expect");
            list_store.append (out iter);
            list_store.set (iter, 0, "Forwarded");
            list_store.append (out iter);
            list_store.set (iter, 0, "From");
            list_store.append (out iter);
            list_store.set (iter, 0, "Host");
            list_store.append (out iter);
            list_store.set (iter, 0, "If-Match");
            list_store.append (out iter);
            list_store.set (iter, 0, "If-Modified-Since ");
            list_store.append (out iter);
            list_store.set (iter, 0, "If-None-Match");
            list_store.append (out iter);
            list_store.set (iter, 0, "If-Range");
            list_store.append (out iter);
            list_store.set (iter, 0, "If-Unmodified-Since");
            list_store.append (out iter);
            list_store.set (iter, 0, "Max-Forwards");
            list_store.append (out iter);
            list_store.set (iter, 0, "Pragma");
            list_store.append (out iter);
            list_store.set (iter, 0, "Proxy-Authorization");
            list_store.append (out iter);
            list_store.set (iter, 0, "Range");
            list_store.append (out iter);
            list_store.set (iter, 0, "Referer");
            list_store.append (out iter);
            list_store.set (iter, 0, "TE");
            list_store.append (out iter);
            list_store.set (iter, 0, "Transfer-Encoding");
            list_store.append (out iter);
            list_store.set (iter, 0, "Upgrade");
            list_store.append (out iter);
            list_store.set (iter, 0, "User-Agent");
            list_store.append (out iter);
            list_store.set (iter, 0, "Via");
            list_store.append (out iter);
            list_store.set (iter, 0, "Warning");


            return completion;
        }

        private static Gtk.EntryCompletion common_content_type_completion () {
            Gtk.EntryCompletion completion = new Gtk.EntryCompletion ();

            // Create, fill & register a ListStore:
            Gtk.ListStore list_store = new Gtk.ListStore (1, typeof (string));
            completion.set_model (list_store);
            completion.set_text_column (0);
            Gtk.TreeIter iter;

            list_store.append (out iter);
            list_store.set (iter, 0, "application/x-abiword");
            list_store.append (out iter);
            list_store.set (iter, 0, "application/x-csh");
            list_store.append (out iter);
            list_store.set (iter, 0, "text/css");
            list_store.append (out iter);
            list_store.set (iter, 0, "text/csv");
            list_store.append (out iter);
            list_store.set (iter, 0, "application/msword");
            list_store.append (out iter);
            list_store.set (iter, 0, "application/vnd.ms-fontobject");
            list_store.append (out iter);
            list_store.set (iter, 0, "image/gif");
            list_store.append (out iter);
            list_store.set (iter, 0, "text/html");
            list_store.append (out iter);
            list_store.set (iter, 0, "image/x-icon");
            list_store.append (out iter);
            list_store.set (iter, 0, "text/calendar");
            list_store.append (out iter);
            list_store.set (iter, 0, "image/jpeg");
            list_store.append (out iter);
            list_store.set (iter, 0, "application/javascript");
            list_store.append (out iter);
            list_store.set (iter, 0, "application/json");
            list_store.append (out iter);
            list_store.set (iter, 0, "audio/midi");
            list_store.append (out iter);
            list_store.set (iter, 0, "video/mpeg");
            list_store.append (out iter);
            list_store.set (iter, 0, "application/vnd.apple.installer+xml");
            list_store.append (out iter);
            list_store.set (iter, 0, "application/vnd.oasis.opendocument.presentation");
            list_store.append (out iter);
            list_store.set (iter, 0, "application/vnd.oasis.opendocument.spreadsheet");
            list_store.append (out iter);
            list_store.set (iter, 0, "application/vnd.oasis.opendocument.text");
            list_store.append (out iter);
            list_store.set (iter, 0, "audio/ogg");
            list_store.append (out iter);
            list_store.set (iter, 0, "video/ogg");
            list_store.append (out iter);
            list_store.set (iter, 0, "application/ogg");
            list_store.append (out iter);
            list_store.set (iter, 0, "font/otf");
            list_store.append (out iter);
            list_store.set (iter, 0, "image/png");
            list_store.append (out iter);
            list_store.set (iter, 0, "application/pdf");
            list_store.append (out iter);
            list_store.set (iter, 0, "application/vnd.ms-powerpoint");
            list_store.append (out iter);
            list_store.set (iter, 0, "application/vnd.openxmlformats-officedocument.presentationml.presentation");
            list_store.append (out iter);
            list_store.set (iter, 0, "application/rtf");
            list_store.append (out iter);
            list_store.set (iter, 0, "application/x-sh");
            list_store.append (out iter);
            list_store.set (iter, 0, "image/svg+xml");
            list_store.append (out iter);
            list_store.set (iter, 0, "image/tiff");
            list_store.append (out iter);
            list_store.set (iter, 0, "application/typescript");
            list_store.append (out iter);
            list_store.set (iter, 0, "font/ttf");
            list_store.append (out iter);
            list_store.set (iter, 0, "application/xml");
            list_store.append (out iter);
            list_store.set (iter, 0, "application/xhtml+xml");
            list_store.append (out iter);
            list_store.set (iter, 0, "application/vnd.ms-excel");

            return completion;
       }
    }
}
