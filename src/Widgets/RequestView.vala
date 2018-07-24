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
        private HeaderView url_params_view;
        private Granite.Widgets.ModeButton tabs;

        public signal void response_received(ResponseItem it);

        construct {
            orientation = Gtk.Orientation.VERTICAL;
            margin = 4;
        }

        public RequestView (RequestController req_ctrl) {
            url_entry = new UrlEntry ();
            header_view = new HeaderView (req_ctrl);
            url_params_view = new HeaderView (req_ctrl);
            url_entry.margin_bottom = 10;
            req_ctrl.register_view (this);

            url_entry.url_changed.connect ((url) => {
                req_ctrl.selected_item.uri = url;
            });

            url_entry.method_changed.connect ((method) => {
                req_ctrl.selected_item.method = method;
            });

            url_entry.request_activated.connect (() => {
                req_ctrl.perform_request ();
            });

            var stack = new Gtk.Stack ();
            stack.margin = 6;
            stack.margin_bottom = 18;
            stack.margin_top = 18;

            stack.add_titled (header_view, "header", _("Header"));
            stack.add_titled (url_params_view, "url_params", _("URL Params"));
            stack.add_titled (new Gtk.Label ("12435243"), "body", _("Body"));

            add (url_entry);

            tabs = new Granite.Widgets.ModeButton ();
            var header_params_label = new Gtk.Label ("Headers");
            var url_params_label = new Gtk.Label ("URL Params");
            var body_label = new Gtk.Label ("Body");
            int current_index = 0;
            body_label.sensitive = false;
            tabs.append (header_params_label);
            tabs.append (url_params_label);
            tabs.append (body_label);
            tabs.set_active (0);
            stack.set_visible_child_name ("header");
            tabs.mode_changed.connect ((tab) => {
                if (tab == body_label ) {
                    if (body_label.sensitive == false) {
                        tabs.set_active (current_index);
                        return;
                    }
                    stack.set_visible_child_name ("body");
                    current_index = tabs.selected;
                } else if (tab == header_params_label) {
                    stack.set_visible_child_name ("header");
                    current_index = tabs.selected;
                } else if (tab == url_params_label) {
                    stack.set_visible_child_name ("url_params");
                    current_index = tabs.selected;
                }

            });

            selected_item_changed.connect (() => {
                var selected_item = req_ctrl.selected_item;
                set_item (selected_item);

                selected_item.notify.connect (() => {
                    update_tabs (body_label, selected_item);
                });

                update_tabs (body_label, selected_item);
            });

            add (tabs);
            add (stack);
        }

        private void update_tabs(Gtk.Widget body_selector, RequestItem item) {
            if (item.method == Method.POST || item.method == Method.PUT || item.method == Method.PATCH) {
                body_selector.sensitive = true;
            } else {
                if (tabs.selected == 2) {
                    tabs.set_active (0);
                }
                body_selector.sensitive = false;
            }
        }

        public void set_item (RequestItem item) {
            url_entry.change_status (item.status);
            url_entry.set_text (item.uri);
            url_entry.set_method (item.method);
            show_all ();
        }
    }
}
