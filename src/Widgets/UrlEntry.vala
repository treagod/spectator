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
    public class UrlEntry : Gtk.Grid {
        private Gtk.ComboBoxText method_box;
        private Gtk.Entry url_entry;
        private bool processing = false;

        public signal void url_changed (string url);
        public signal void method_changed(Method method);
        public signal void request_activated ();
        public signal void cancel_process ();

        public UrlEntry () {
            init_method_box ();
            init_url_entry ();
            margin_top = 4;
            margin_bottom = 4;
            url_entry.key_press_event.connect ((event) => {
                if (event.keyval == Gdk.Key.question) {
                    // Test if valid URL
                    // Add Parameter to url parameters
                    stdout.printf ("asd\n");
                }

                return false;
            });

            url_entry.changed.connect (() => {
                url_changed (url_entry.text);
            });

        }

        private void init_method_box () {
            method_box = new Gtk.ComboBoxText ();
            method_box.append_text ("GET");
            method_box.append_text ("POST");
            method_box.append_text ("PUT");
            method_box.append_text ("PATCH");
            method_box.append_text ("DELETE");
            method_box.append_text ("HEAD");
            method_box.active = 0;

            method_box.changed.connect (() => {
                var index = method_box.get_active ();
                method_changed (Method.convert(index));
            });

            add (method_box);
        }

        public void set_text (string url) {
            url_entry.text = url;
        }

        public void set_method (Method method) {
            method_box.active = method.to_i ();
        }

        public void item_status_changed (RequestStatus status) {
            switch (status) {
                case RequestStatus.SENT:
                    url_entry.set_icon_from_icon_name (Gtk.EntryIconPosition.SECONDARY, "view-refresh-symbolic");
                    processing = false;
                    break;
                case RequestStatus.NOT_SENT:
                    url_entry.set_icon_from_icon_name (Gtk.EntryIconPosition.SECONDARY, "media-playback-start-symbolic");
                    processing = false;
                    break;
                case RequestStatus.SENDING:
                    url_entry.set_icon_from_icon_name (Gtk.EntryIconPosition.SECONDARY, "window-close-symbolic");
                    processing = true;
                    break;
            }
        }

        private void init_url_entry () {
            url_entry = new Gtk.Entry ();
            url_entry.placeholder_text = "Type an URL";
            url_entry.set_icon_from_icon_name (Gtk.EntryIconPosition.SECONDARY, "media-playback-start-symbolic");

            url_entry.icon_press.connect (() => {
                if (processing) {
                    cancel_process ();
                } else {
                    widget_activate ();
                }
            });

            url_entry.activate.connect (() => {
                if (processing) {
                    cancel_process ();
                } else {
                    widget_activate ();
                }

            });
            url_entry.hexpand = true;
            add (url_entry);
        }

        private void widget_activate () {
            request_activated ();
        }
    }
}
