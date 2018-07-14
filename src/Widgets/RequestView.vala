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
    class RequestView : Gtk.Box, View.Request {
        private UrlEntry url_entry;
        private HeaderView header_view;

        public signal void response_received(ResponseItem it);

        construct {
            orientation = Gtk.Orientation.VERTICAL;
            margin = 4;
        }

        public RequestView (RequestController req_ctrl) {
            url_entry = new UrlEntry ();
            header_view = new HeaderView (req_ctrl);
            url_entry.margin_bottom = 10;
            req_ctrl.register_view (this);

            selected_item_updated.connect (() => {
                set_item (req_ctrl.selected_item);
            });

            url_entry.url_changed.connect ((url) => {
                req_ctrl.selected_item.domain = url;
            });

            url_entry.method_changed.connect ((method) => {
                req_ctrl.selected_item.method = method;
            });

            url_entry.request_activated.connect (perform_request);

            var stack = new Gtk.Stack ();
            stack.margin = 6;
            stack.margin_bottom = 18;
            stack.margin_top = 18;
            var stack_switcher = new Gtk.StackSwitcher ();
            stack_switcher.set_stack (stack);
            stack_switcher.halign = Gtk.Align.CENTER;

            stack.add_titled (header_view, "header", _("Header"));
            stack.add_titled (new Gtk.Label ("12435243"), "url_params", _("URL Parameters"));
            stack.add_titled (new Gtk.Label ("12435243"), "body", _("Body"));
            stack.add_titled (new Gtk.Label ("12435243"),"Auth", "Auth");
            stack.add_titled (new Gtk.Label ("12435243"),"Options", "Options");

            add (url_entry);
            add (stack_switcher);
            add (stack);
        }

        public void set_item (RequestItem item) {
            url_entry.item_status_changed (item.status);
            url_entry.set_text (item.domain);
            url_entry.set_method (item.method);
            show_all ();
        }

        private async void perform_request () {
        }
    }
}
