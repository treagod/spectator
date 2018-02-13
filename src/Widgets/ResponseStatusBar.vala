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

            .dark-ok-status-box {
                border-width: 1px;
                border-style: solid;
                border-color: #68b723;
                color: #68b723;
                background-color: #333333;
            }

            .dark-error-status-box {
                border-width: 1px;
                border-style: solid;
                border-color: #c6262e;
                color: #c6262e;
                background-color: #333333;
            }

            .dark-redirect-status-box {
                border-width: 1px;
                border-style: solid;
                border-color: #f9c440;
                color: #f9c440;
                background-color: #333333;
            }

            .dark-response-info-box {
                border-width: 1px;
                border-style: solid;
                border-color: #d4d4d4;
                color: #d4d4d4 ;
                background-color: #333333;
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
            http_status_box.get_style_context ().remove_class ("redirect-status-box");
            http_status_box.get_style_context ().remove_class ("error-status-box");
            http_status_box.get_style_context ().remove_class ("dark-ok-status-box");
            http_status_box.get_style_context ().remove_class ("dark-redirect-status-box");
            http_status_box.get_style_context ().remove_class ("dark-error-status-box");
            http_status_box.get_style_context ().remove_class ("response-info-box");
            response_size_box.get_style_context ().remove_class ("response-info-box");
            response_size_box.get_style_context ().remove_class ("dark-response-info-box");
            response_size_box.get_style_context ().remove_class ("no-info-box");
            request_time_box.get_style_context ().remove_class ("no-info-box");
            request_time_box.get_style_context ().remove_class ("response-info-box");
            request_time_box.get_style_context ().remove_class ("dark-response-info-box");
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
                var seconds = _("seconds");
                var formated_time = "%.2f ".printf (it.duration);
                http_status_label.label = "%u Ok".printf (it.status_code);
                response_size_label.label = ("%" + int64.FORMAT + " KB").printf (it.size / 1000);
                request_time_label.label = formated_time + seconds;
                response_size_box.get_style_context ().add_class (response_info_box ());
                response_size_label.halign = Gtk.Align.CENTER;
                request_time_box.get_style_context ().add_class (response_info_box ());
                request_time_box.halign = Gtk.Align.CENTER;
                http_status_box.get_style_context ().add_class (status_color (it.status_code));
                http_status_box.halign = Gtk.Align.CENTER;
            }
            // Force redraw, otherwise box borders won't match the labels
            queue_draw ();
        }
    }

    private string response_info_box () {
        if (Gtk.Settings.get_default ().gtk_application_prefer_dark_theme) {
            return "dark-response-info-box";
        } else {
            return "response-info-box";
        }
    }

    private string status_color (uint status) {
        if (Gtk.Settings.get_default ().gtk_application_prefer_dark_theme) {
            if (status >= 200 && status < 300) {
                return "dark-ok-status-box";
            } else if (status >= 300 && status < 400) {
                return "dark-redirect-status_box";
            } else if (status >= 400 && status < 600) {
                return "dark-error-status-box";
            } else {
                return "response-info-box";
            }
        } else {
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
}
