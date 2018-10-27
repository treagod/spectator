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

namespace HTTPInspector.Widgets.Request {
    class Container : Gtk.Box, Interface {
        private UrlEntry url_entry;
        private KeyValueList header_view;
        private BodyView body_view;
        private KeyValueList url_params_view;
        private Granite.Widgets.ModeButton tabs;
        private Gtk.Stack stack;
        private Gtk.Label body_label;

        public signal void response_received(ResponseItem it);

        construct {
            orientation = Gtk.Orientation.VERTICAL;
            margin = 4;
        }

        public Container () {
            url_entry = new UrlEntry ();
            header_view = new KeyValueList (_("Add Header"));
            url_params_view = new KeyValueList (_("Add URL Parameter"));
            url_entry.margin_bottom = 10;

            url_params_view.item_updated.connect (() => {
                url_params_updated (url_params_view.get_all_items ());
            });

            url_params_view.item_added.connect ((url) => {
                //
            });

            header_view.item_added.connect ((header) => {
                header_added (header);
            });

            header_view.item_deleted.connect ((header) => {
                header_deleted (header);
            });

            url_params_view.item_added.connect ((url_param) => {
            });

            url_params_view.item_deleted.connect ((url_param) => {
            });

            url_entry.url_changed.connect ((url) => {
                url_changed (url);
            });

            url_entry.method_changed.connect ((method) => {
                method_changed (method);
                update_tabs (method);
            });

            url_entry.request_activated.connect (() => {
                request_activated ();
            });

            body_view = new BodyView ();

            stack = new Gtk.Stack ();
            stack.margin = 0;
            stack.margin_bottom = 18;
            stack.margin_top = 18;

            stack.add_titled (header_view, "header", _("Header"));
            stack.add_titled (url_params_view, "url_params", _("URL Params"));
            stack.add_titled (body_view, "body", _("Body"));

            add (url_entry);

            var header_params_label = new Gtk.Label ("Headers");
            var url_params_label = new Gtk.Label ("URL Params");
            body_label = new Gtk.Label ("Body");

            setup_tabs (header_params_label, url_params_label, body_label);

            body_label.sensitive = false;

            stack.set_visible_child_name ("header");

            add (tabs);
            add (stack);
        }

        public void update_url_params (RequestItem item) {
            var query = item.query;
            var params = query.split("&");
            url_params_view.clear ();

            foreach (var param in params) {
                if (param != "") {
                    var kv = param.split("=");
                    if(kv.length == 2){
                        url_params_view.add_field (new Pair(kv[0], kv[1]));
                    } else if (kv.length == 1) {
                        url_params_view.add_field (new Pair(kv[0], ""));
                    }

                }
            }
        }

        private void setup_tabs (Gtk.Label header_params_label,
                Gtk.Label url_params_label, Gtk.Label body_label) {
            tabs = new Granite.Widgets.ModeButton ();
            int current_index = 0;

            tabs.append (header_params_label);
            tabs.append (url_params_label);
            tabs.append (body_label);
            tabs.set_active (0);

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
        }

        // update_tabs checks on item change which HTTP method is selected.
        // When POST, PUT or PATCH is selected the user will be able to
        // select the Body Tab
        // For all other methods this method checks if the Body Tab was selected. If
        // the Body tab was selected, select Headers Tab. Furthermore disable Body Tab
        private void update_tabs(Method method) {
            if (method == Method.POST || method == Method.PUT || method == Method.PATCH) {
                body_label.sensitive = true;
            } else {
                if (tabs.selected == 2) {
                    tabs.set_active (0);
                }
                body_label.sensitive = false;
            }
        }

        private void set_headers (Gee.ArrayList<Pair> headers) {
            header_view.change_rows (headers);
        }

        public void update_url_bar (string uri) {
            url_entry.set_text (uri);
        }

        public void set_item (RequestItem item) {
            url_entry.change_status (item.status);
            url_entry.set_text (item.uri);
            url_entry.set_method (item.method);
            update_url_params (item);
            update_tabs (item.method);
            set_headers (item.headers);
            show_all ();
        }
    }
}
