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

namespace Spectator.Widgets.Response.StatusBar {
    public enum Type {
        HTML, JSON, XML, UNKOWN
    }

    class Container : Gtk.Box {
        private Gtk.Box http_status_box;
        private Gtk.Label http_status_label;
        private Gtk.Box request_time_box;
        private Gtk.Label request_time_label;
        private Gtk.Box response_size_box;
        private Gtk.Label response_size_label;
        private Models.Response? item;

        construct {
            orientation = Gtk.Orientation.HORIZONTAL;
            spacing = 7;
            get_style_context ().add_class ("response-statusbar");

            http_status_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL,9);
            http_status_label = new Gtk.Label (_("No status"));
            http_status_box.get_style_context ().add_class ("no-info-box");
            http_status_label.halign = Gtk.Align.CENTER;
            http_status_label.margin = 5;

            http_status_box.add (http_status_label);

            request_time_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL,9);
            request_time_label = new Gtk.Label (_("No duration"));
            request_time_box.get_style_context ().add_class ("no-info-box");
            request_time_label.halign = Gtk.Align.CENTER;
            request_time_label.margin = 5;

            request_time_box.add (request_time_label);

            response_size_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL,9);
            response_size_label = new Gtk.Label (_("No size"));
            response_size_box.get_style_context ().add_class ("no-info-box");
            response_size_label.halign = Gtk.Align.CENTER;
            response_size_label.margin = 5;

            response_size_box.add (response_size_label);

            add (http_status_box);
            add (request_time_box);
            add (response_size_box);

            Settings.get_instance ().theme_changed.connect (() => {
                update (item);
            });
        }

        public void update (Models.Response? it) {
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
                response_size_label.label = _("No size");
                request_time_box.get_style_context ().add_class ("no-info-box");
                request_time_box.halign = Gtk.Align.CENTER;
                request_time_label.label = _("No duration");
                http_status_box.get_style_context ().add_class ("no-info-box");
                http_status_box.halign = Gtk.Align.CENTER;
                http_status_label.label = _("No status");
            } else {
                http_status_label.label = "%u %s".printf (it.status_code, Soup.Status.get_phrase (it.status_code));
                response_size_label.label = human_readable_bytes (it.size);
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

        private string human_readable_bytes (int64 response_size) {
            if (response_size >= 1000000000) {
                return ("%" + int64.FORMAT + " " + _("GB")).printf (response_size / 1000000000);
            } else if (response_size >= 1000000) {
                return ("%" + int64.FORMAT + " " + _("MB")).printf (response_size / 1000000);
            } else if (response_size >= 1000) {
                return ("%" + int64.FORMAT + " " + _("KB")).printf (response_size / 1000);
            }

            // Assuming nobody is downloading more or equal than 1 TB...
            // if you do, please give send me an email with proof (marv.ahlgrimm@gmail.com)
            return ("%" + int64.FORMAT + " " + _("B")).printf (response_size);
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
