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
    class ResponseStatusBar : Gtk.Box {
        private const string CSS = """
            .ok-status-box {
                border-width: 1px;
                border-style: solid;
                border-color: #3a9104;
                color: #3a9104;
                background-color: #fafafa;
            }

            .error-status-box {
                border-width: 1px;
                border-style: solid;
                border-color: #a10705;
                color: #a10705;
                background-color: #fafafa;
            }

            .redirect-status-box {
                border-width: 1px;
                border-style: solid;
                border-color: #d48e15;
                color: #d48e15;
                background-color: #fafafa;
            }

            .response-info-box {
                border-width: 1px;
                border-style: solid;
                border-color: #273445;
                color: #273445 ;
                background-color: #fafafa;
            }

            .no-info-box {
                border-width: 1px;
                border-style: solid;
                border-color: #fafafa;
                color: #fafafa;
                background-color: #273445;
            }
        """;


        private Gtk.Box http_status_box;
        private Gtk.Label http_status_label;
        private Gtk.Box request_time_box;
        private Gtk.Label request_time_label;
        private Gtk.Box response_size_box;
        private Gtk.Label response_size_label;

        static construct {
            var provider = new Gtk.CssProvider ();
            try {
                provider.load_from_data (CSS, CSS.length);
                Gtk.StyleContext.add_provider_for_screen (Gdk.Screen.get_default (), provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
            } catch (Error e) {
                critical (e.message);
            }
        }

        construct {
            orientation = Gtk.Orientation.HORIZONTAL;
            spacing = 7;
            margin_left = 15;

            http_status_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL,9);
            http_status_label = new Gtk.Label ("No Status");
            http_status_box.get_style_context ().add_class ("no-info-box");
            http_status_label.halign = Gtk.Align.CENTER;
            http_status_label.margin = 5;

            http_status_box.add (http_status_label);

            request_time_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL,9);
            request_time_label = new Gtk.Label ("No duration");
            request_time_box.get_style_context ().add_class ("no-info-box");
            request_time_label.halign = Gtk.Align.CENTER;
            request_time_label.margin = 5;

            request_time_box.add (request_time_label);

            response_size_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL,9);
            response_size_label = new Gtk.Label ("No size");
            response_size_box.get_style_context ().add_class ("no-info-box");
            response_size_label.halign = Gtk.Align.CENTER;
            response_size_label.margin = 5;

            response_size_box.add (response_size_label);

            add (http_status_box);
            add (request_time_box);
            add (response_size_box);
        }

        public void update (ResponseItem? it) {
            http_status_box.get_style_context ().remove_class ("ok-status-box");
            http_status_box.get_style_context ().remove_class ("error-status-box");
            http_status_box.get_style_context ().remove_class ("response-info-box");
            response_size_box.get_style_context ().remove_class ("response-info-box");
            response_size_box.get_style_context ().remove_class ("no-info-box");
            request_time_box.get_style_context ().remove_class ("no-info-box");
            request_time_box.get_style_context ().remove_class ("response-info-box");
            http_status_box.get_style_context ().remove_class ("no-info-box");

            if (it == null) {
                response_size_box.get_style_context ().add_class ("no-info-box");
                response_size_label.halign = Gtk.Align.CENTER;
                response_size_label.label = "No size";
                request_time_box.get_style_context ().add_class ("no-info-box");
                request_time_box.halign = Gtk.Align.CENTER;
                request_time_label.label = "No duration";
                http_status_box.get_style_context ().add_class ("no-info-box");
                http_status_box.halign = Gtk.Align.CENTER;
                http_status_label.label = "No status";
            } else {
                http_status_label.label = "%u Ok".printf (it.status_code);
                response_size_label.label = ("%" + int64.FORMAT + " KB").printf (it.size / 1000);
                request_time_label.label = "%.2f seconds".printf (it.duration);
                response_size_box.get_style_context ().add_class ("response-info-box");
                response_size_label.halign = Gtk.Align.CENTER;
                request_time_box.get_style_context ().add_class ("response-info-box");
                request_time_box.halign = Gtk.Align.CENTER;
                http_status_box.get_style_context ().add_class (status_color (it.status_code));
                http_status_box.halign = Gtk.Align.CENTER;
            }
            // Force redraw, otherwise box borders won't match the labels
            queue_draw ();
        }
    }

    private string status_color (uint status) {
        stdout.printf ("%u", status);
        if (status >= 200 && status < 300) {
            return "ok-status-box";
        } else if (status >= 300 && status < 400) {
            return "redirect-status_box";
        } else if (status >= 400 && status < 600) {
            return "error-status-box";
        } else {
            return "response-info-box";
        }
    }
}

/*
var box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);

var status_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL,9);
var label = new Gtk.Label ("200 Ok");
label.margin = 5;
status_box.pack_start (label, false, false);
box.pack_start (status_box, false, false);
status_box.margin_left = 15;
status_box.get_style_context ().add_class ("status-box");

var status_box2 = new Gtk.Box (Gtk.Orientation.HORIZONTAL,9);
var label2 = new Gtk.Label ("Time 13.2 s");
label2.margin = 5;
status_box2.pack_start (label2, false, false);
status_box2.get_style_context ().add_class ("response-info-box");

var status_box3 = new Gtk.Box (Gtk.Orientation.HORIZONTAL,9);
var label3 = new Gtk.Label ("Size 11.6 KB");
label3.margin = 5;
status_box3.pack_start (label3, false, false);
status_box3.get_style_context ().add_class ("response-info-box");

box.pack_start (status_box2, false, false);
box.pack_start (status_box3, false, false);

box.spacing = 7;

pack_start (box, false, false, 15);
*/
