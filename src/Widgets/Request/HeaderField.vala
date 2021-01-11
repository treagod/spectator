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

namespace Spectator.Widgets.Request {
    class HeaderField : KeyValueField {
        public HeaderField () {
            base ();
            setup ();
        }
        public HeaderField.with_value (Pair header) {
            base.with_value (header);
            setup ();
        }

        private void setup () {
            value_field.focus_in_event.connect (() => {
                // Change Completion According to header key
                switch (key_field.text) {
                    case "Content-Type":
                        value_field.set_completion (common_content_type_completion ());
                        break;
                    case "User-Agent":
                        value_field.set_completion (common_user_agent_completion ());
                        break;
                    default:
                        value_field.set_completion (null);
                        break;
                }

                return false;
            });

            value_field.focus_out_event.connect (() => {
                // Only emit if both entries are filled
                if (key_field.text != "" && key_field.text != null) {
                    item.val = val;
                }

                return false;
            });

            value_field.changed.connect (() => {
                // Only emit if both entries are filled
                if (key_field.text != "" && key_field.text != null) {
                    item.val = val;
                }
            });

            key_field.focus_out_event.connect (() => {
                // Only emit if both entries are filled
                item.key = key;

                return false;
            });

            key_field.changed.connect (() => {
                item.key = key;
            });

            key_field.hexpand = true;
            value_field.hexpand = true;

            key_field.set_completion (common_header_key_completion ());
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

        private static Gtk.EntryCompletion common_user_agent_completion () {
            Gtk.EntryCompletion completion = new Gtk.EntryCompletion ();

            // Create, fill & register a ListStore:
            Gtk.ListStore list_store = new Gtk.ListStore (1, typeof (string));
            completion.set_model (list_store);
            completion.set_text_column (0);
            Gtk.TreeIter iter;

            list_store.append (out iter);
            list_store.set (iter, 0, "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/63.0.3239.132 Safari/537.36");
            list_store.append (out iter);
            list_store.set (iter, 0,"Mozilla/5.0 (Windows NT 6.1; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/63.0.3239.132 Safari/537.36");
            list_store.append (out iter);
            list_store.set (iter, 0,"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/63.0.3239.132 Safari/537.36");
            list_store.append (out iter);
            list_store.set (iter, 0,"Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:58.0) Gecko/20100101 Firefox/58.0");
            list_store.append (out iter);
            list_store.set (iter, 0,"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_2) AppleWebKit/604.4.7 (KHTML, like Gecko) Version/11.0.2 Safari/604.4.7");
            list_store.append (out iter);
            list_store.set (iter, 0,"Mozilla/5.0 (Windows NT 6.3; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/63.0.3239.132 Safari/537.36");
            list_store.append (out iter);
            list_store.set (iter, 0,"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/63.0.3239.132 Safari/537.36");
            list_store.append (out iter);
            list_store.set (iter, 0,"Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/63.0.3239.132 Safari/537.36");

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
