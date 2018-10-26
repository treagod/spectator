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

namespace HTTPInspector.Widgets {
    public class Content : Gtk.Box {
        private Gtk.Stack stack;
        private Granite.Widgets.Welcome welcome;
        private RequestResponsePane req_res_pane;
        private Request.Container request_view;
        private Gtk.InfoBar infobar;
        private Gtk.Label infolabel;

        public signal void url_changed (string url);
        public signal void method_changed (Method method);
        public signal void request_activated ();
        public signal void cancel_process ();

        public signal void item_changed (RequestItem item);
        public signal void welcome_activated(int index);
        public signal void header_added (Header header);
        public signal void header_deleted (Header header);

        public Content () {
            stack = new Gtk.Stack ();
            infobar = new Gtk.InfoBar ();
            infolabel = new Gtk.Label("");
            welcome = new Granite.Widgets.Welcome (_("HTTP Inspector"), _("Inspect your HTTP transmissions to the web"));
            welcome.hexpand = true;
            welcome.append ("bookmark-new", _("Create Request"), _("Create a new request to the web."));

            welcome.activated.connect((index) => {
                welcome_activated (index);
            });

            request_view = new Request.Container ();
            req_res_pane = new RequestResponsePane ();
            req_res_pane.url_changed.connect ((url) => {
                url_changed (url);
            });

            req_res_pane.request_activated.connect (() => {
                request_activated ();
            });

            req_res_pane.method_changed.connect((method) => {
                method_changed (method);
            });

            req_res_pane.header_added.connect ((header) => {
                header_added (header);
            });

            req_res_pane.header_deleted.connect ((header) => {
                header_deleted (header);
            });

            // Request View
            request_view.url_changed.connect ((url) => {
                url_changed (url);
            });

            request_view.request_activated.connect (() => {
                request_activated ();
            });

            request_view.method_changed.connect((method) => {
                method_changed (method);
            });

            request_view.header_added.connect ((header) => {
                header_added (header);
            });

            request_view.header_deleted.connect ((header) => {
                header_deleted (header);
            });

            stack.add_named (welcome, "welcome");
            stack.add_named (req_res_pane, "req_res_pane");
            stack.add_named (request_view, "response_view");

            stack.set_visible_child (welcome);
            infobar.show_close_button = true;
            infobar.revealed = false;

            infobar.response.connect (() => {
                infobar.revealed = false;
            });

            Gtk.Container content = infobar.get_content_area ();
            content.add (infolabel);
		    content.show_all ();

            add  (infobar);
            add (stack);

            show_all ();
        }

        construct {
            orientation = Gtk.Orientation.VERTICAL;
            margin = 0;
        }

        public void set_warning (string message) {
            infobar.message_type = Gtk.MessageType.WARNING;

            reveal_infobar (message);
        }

        public void set_error (string message) {
            infobar.message_type = Gtk.MessageType.ERROR;

            reveal_infobar (message);
        }

        private void reveal_infobar (string message) {
            infolabel.label = message;
		    infobar.revealed = true;
        }

        public void show_request (RequestItem item) {
            if (item.response == null) {
                request_view.set_item (item);
                stack.set_visible_child (request_view);
            } else {
                req_res_pane.set_item (item);
                stack.set_visible_child (req_res_pane);
            }
        }

        public void show_welcome () {
            stack.set_visible_child (welcome);
        }
    }

}
