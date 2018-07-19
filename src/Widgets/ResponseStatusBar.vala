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
    public enum ResponseType {
        HTML, JSON, XML, UNKOWN
    }

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
        private Gtk.Stack content_type;
        private ResponseItem? item;

        public signal void view_changed (int i);

        static construct {
            var provider = new Gtk.CssProvider ();
            try {
                provider.load_from_data (CSS, CSS.length);
                Gtk.StyleContext.add_provider_for_screen (Gdk.Screen.get_default (), provider,
                                                          Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
            } catch (Error e) {
                critical (e.message);
            }
        }

        construct {
            orientation = Gtk.Orientation.HORIZONTAL;
            spacing = 7;
            margin_left = 15;
            content_type = new Gtk.Stack ();

            content_type.add_named (new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0),
                                    "no-type");

            var html_selection = new Gtk.ComboBoxText ();

            html_selection.append_text (_("Preview"));
            html_selection.append_text (_("Source Code"));
            html_selection.active = 0;

            html_selection.changed.connect (() => {
                view_changed (html_selection.get_active ());
            });

            var json_selection = new Gtk.ComboBoxText ();

            json_selection.append_text (_("Prettified"));
            json_selection.append_text (_("Raw"));
            json_selection.active = 0;

            json_selection.changed.connect (() => {
                view_changed (json_selection.get_active ());
            });

            http_status_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL,9);
            http_status_label = new Gtk.Label ("No Status");
            http_status_box.get_style_context ().add_class ("no-info-box");
            http_status_label.halign = Gtk.Align.CENTER;
            http_status_label.margin = 3;

            http_status_box.add (http_status_label);

            request_time_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL,9);
            request_time_label = new Gtk.Label ("No duration");
            request_time_box.get_style_context ().add_class ("no-info-box");
            request_time_label.halign = Gtk.Align.CENTER;
            request_time_label.margin = 3;

            request_time_box.add (request_time_label);

            response_size_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL,9);
            response_size_label = new Gtk.Label ("No size");
            response_size_box.get_style_context ().add_class ("no-info-box");
            response_size_label.halign = Gtk.Align.CENTER;
            response_size_label.margin = 3;

            response_size_box.add (response_size_label);

            add (http_status_box);
            add (request_time_box);
            add (response_size_box);

            content_type.add_named (html_selection, "html_selection");
            content_type.add_named (json_selection  , "json_selection");
            content_type.set_visible_child_name ("no-type");

            Settings.get_instance ().theme_changed.connect (() => {
                update (item);
            });

            pack_end (content_type, false, false);
        }

        public void update (ResponseItem? it) {
            item = it;
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
                http_status_label.label = "%u %s".printf (it.status_code, status_code_text (it.status_code));
                response_size_label.label = ("%" + int64.FORMAT + " KB").printf (it.size / 1000);
                request_time_label.label = "%.2f %s".printf (it.duration, _("seconds"));
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

        public void set_active_type (ResponseType typ) {
            switch (typ) {
                case ResponseType.HTML:
                    content_type.set_visible_child_name ("html_selection");
                    break;
                case ResponseType.JSON:
                    content_type.set_visible_child_name ("json_selection");
                    break;
                case ResponseType.XML:
                    content_type.set_visible_child_name ("xml_selection");
                    break;
                default:
                    content_type.set_visible_child_name ("no-type");
                    break;
            }

            if (content_type.visible_child_name != "no-type") {
                var combo = (Gtk.ComboBoxText) content_type.get_visible_child ();
                combo.active = 0;
            }
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

    private string status_code_text (uint code) {
        switch (code) {
            case 100:
                return "Continue";
            case 101:
                return "Switching Protocols";
            case 102:
                return "Processing";
            case 200:
                return "OK";
            case 201:
                return "Created";
            case 202:
                return "Accepted";
            case 203:
                return "Non-Authoritative Information";
            case 204:
                return "No Content";
            case 205:
                return "Reset Content";
            case 206:
                return "Partial Content";
            case 207:
                return "Multi-Status";
            case 208:
                return "Already Reported";
            case 226:
                return "IM Used";
            case 300:
                return "Multiple Choices";
            case 301:
                return "Moved Permanently";
            case 302:
                return "Found (Moved Temporarily)";
            case 303:
                return "See Other";
            case 304:
                return "Not Modified";
            case 305:
                return "Use Proxy";
            case 307:
                return "Temporary Redirect";
            case 308:
                return "Permanent Redirect";
            case 400:
                return "Bad Request";
            case 401:
                return "Unauthorized";
            case 402:
                return "Payment Required";
            case 403:
                return "Forbidden";
            case 404:
                return "Not Found";
            case 405:
                return "Method Not Allowed";
            case 406:
                return "Not Acceptable";
            case 407:
                return "Proxy Authentication Required";
            case 408:
                return "Request Time-out";
            case 409:
                return "Conflict";
            case 410:
                return "Gone";
            case 411:
                return "Length Required";
            case 412:
                return "Precondition Failed";
            case 413:
                return "Request Entity Too Large";
            case 414:
                return "URI Too Long";
            case 415:
                return "Unsupported Media Type";
            case 416:
                return "Requested range not satisfiable";
            case 417:
                return "Expectation Failed";
            case 418:
                return "I'm a teapot";
            case 420:
                return "Poly Not Fulfilled";
            case 421:
                return "Misdirected Request";
            case 422:
                return "Unprocessable Entity";
            case 423:
                return "Locked";
            case 424:
                return "Failed Dependency";
            case 425:
                return "Unordered Collection";
            case 426:
                return "Upgrade required";
            case 428:
                return "Precondition Required";
            case 429:
                return "Too Many Requests";
            case 431:
                return "Request Header Fields Too Large";
            case 444:
                return "No Response";
            case 449:
                return "This request should be retried after doing the appropriate action";
            case 451:
                return "Unavailable For Legal Reasons";
            case 499:
                return "Client Closed Request";
            case 500:
                return "Internal Server Error";
            case 501:
                return "Not implemented";
            case 502:
                return "Bad Gateway";
            case 503:
                return "Service Unavailable";
            case 504:
                return "Gateway Time-out";
            case 505:
                return "HTTP Version not supported";
            case 506:
                return "Variant Also Negotiates";
            case 507:
                return "Insufficient Storage";
            case 508:
                return "Loop Detected";
            case 509:
                return "Bandwidth Limit Exceeded";
            case 510:
                return "Not Extended";
            case 511:
                return "Network Authentication Required";
            default:
                return "Unkown";
        }
    }
}
