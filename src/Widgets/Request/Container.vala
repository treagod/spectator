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

namespace Spectator.Widgets.Request {
    class Container : Gtk.Box, Interface {
        private UrlEntry url_entry;
        private KeyValueList header_view;
        private BodyView body_view;
        private KeyValueList url_params_view;
        private Spectator.Widgets.Request.Scripting.Container scripting_view;
        private Granite.Widgets.ModeButton tabs;
        private Gtk.Stack stack;

        public int tab_index {
            get {
                return tabs.selected;
            } set {
                tabs.selected = value;
            }
        }

        public signal void body_type_changed (RequestBody.ContentType type);
        public signal void content_changed (string content);
        public signal void body_buffer_changed (string content);
        public signal void script_changed (string script);

        construct {
            orientation = Gtk.Orientation.VERTICAL;
            margin = 4;
        }

        public Container () {
            this.header_view = create_header_view ();
            this.url_params_view = create_url_params_view ();
            this.url_entry = create_url_entry ();
            this.body_view = create_body_view ();
            this.scripting_view = new Spectator.Widgets.Request.Scripting.Container ();

            this.scripting_view.script_changed.connect ((script) => {
                this.script_changed (script);
            });

            this.init_stack ();
            this.stack.set_visible_child_name ("header");
            this.setup_tabs ();

            this.add (url_entry);
            this.add (tabs);
            this.add (stack);
            this.show_all ();
        }

        public void set_url_entry (string request_url) {
            this.url_entry.set_text (request_url);
        }

        public void set_request_body (RequestBody body) {
            this.body_view.set_body_type (body.type);
        }

        public void set_request_url (string request_url) {
            this.url_entry.set_text (request_url);
            this.url_params_view.change_rows (this.convert_query_to_pairs (request_url));
        }

        public void set_request_method (Models.Method method) {
            this.url_entry.set_method (method);
        }

        public void set_script (string script) {
            this.scripting_view.update_script_buffer (script);
        }

        public void set_script_buffer (uint id) {
            this.scripting_view.set_script_buffer (id);
        }

        public void set_body (RequestBody body) {
            this.body_view.set_content (body.content, body.type);
        }

        public void reset_body () {
            this.body_view.reset_content ();
        }

        public void set_headers(Gee.ArrayList<Pair> headers) {
            this.header_view.change_rows (headers);
        }

        private KeyValueList create_header_view () {
            var header_view = new KeyValueList (_("Add Header"));
            header_view.provider = new HeaderProvider ();

            header_view.item_added.connect ((header) => {
                header_added (header_view.get_all_items ());
            });

            header_view.item_updated.connect (() => {
                header_added (header_view.get_all_items ());
            });

            header_view.item_deleted.connect ((header) => {
                header_deleted (header_view.get_all_items ());
            });

            return header_view;
        }

        public void update_buffer (uint id, string text, Services.ConsoleMessageType mt) {
            this.scripting_view.update_buffer (id, text, mt);
        }

        private Gee.ArrayList<Pair> convert_query_to_pairs (string url) {
            var query_pairs = new Gee.ArrayList<Pair> ();
            var query_sep = url.index_of ("?");

            // Only do something if there is a '?'
            if (query_sep >= 0) {
                var query = url.substring (query_sep + 1);

                if (query.strip ().length > 0) {
                    var parameters = query.split ("&");

                    foreach (var param in parameters) {
                        if (param.strip ().length == 0) continue;
                        var key_value = param.split ("=");

                        // When there is a equal sign in the string, add key and value
                        // Otherwise add the string as key and an empty string as value
                        if (key_value.length > 1) {
                            query_pairs.add(new Pair(key_value[0], key_value[1]));
                        } else {
                            query_pairs.add(new Pair(key_value[0], ""));
                        }
                    }
                }
            }

            return query_pairs;
        }

        private UrlEntry create_url_entry () {
            var url_entry = new UrlEntry ();
            url_entry.margin_bottom = 7;

            url_entry.url_changed.connect ((url) => {
                this.url_changed (url);
                this.url_params_view.change_rows (this.convert_query_to_pairs (url));
            });

            url_entry.method_changed.connect ((method) => {
                this.method_changed (method);
            });

            url_entry.request_activated.connect (() => {
                this.request_activated ();
            });

            url_entry.cancel_process.connect (() => {
                this.cancel_process ();
            });

            return url_entry;
        }

        public void set_request_status (Models.RequestStatus status) {
            this.url_entry.set_request_status (status);
        }

        private KeyValueList create_url_params_view () {
            var url_params_view = new KeyValueList (_("Add Parameter"));

            url_params_view.item_updated.connect (() => {
                url_params_updated (url_params_view.get_all_items ());
            });

            url_params_view.item_added.connect ((url) => {
                url_params_updated (url_params_view.get_all_items ());
            });

            url_params_view.item_deleted.connect ((url) => {
                var items = url_params_view.get_all_items ();
                items.remove (url);
                url_params_updated (items);
            });

            return url_params_view;
        }

        private BodyView create_body_view () {
            var body_view = new BodyView ();

            body_view.type_changed.connect ((type) => {
                this.body_type_changed (type);
            });

            body_view.content_changed.connect ((content) => {
                this.content_changed (content);
            });

            return body_view;
        }

        private void init_stack () {
            stack = new Gtk.Stack ();
            stack.margin = 0;
            stack.margin_bottom = 15;
            stack.margin_top = 15;

            stack.add_titled (header_view, "header", "header");
            stack.add_titled (url_params_view, "url_params", "parameters");
            stack.add_titled (body_view, "body", "body");
            stack.add_titled (scripting_view, "scripting", "scripting");
        }

        private void setup_tabs () {
            tabs = new Granite.Widgets.ModeButton ();
            int current_index = 0;

            var header_params_label = new Gtk.Label (_("Headers"));
            var url_params_label = new Gtk.Label (_("Parameters"));
            var script_label = new Gtk.Label (_("Script"));
            var body_label = new Gtk.Label (_("Body"));

            tabs.append (header_params_label);
            tabs.append (url_params_label);
            tabs.append (body_label);
            tabs.append (script_label);
            tabs.set_active (0);

            tabs.mode_changed.connect ((tab) => {
                if (tab == body_label ) {
                    stack.set_visible_child_name ("body");
                    current_index = tabs.selected;
                } else if (tab == header_params_label) {
                    stack.set_visible_child_name ("header");
                    current_index = tabs.selected;
                } else if (tab == url_params_label) {
                    stack.set_visible_child_name ("url_params");
                    current_index = tabs.selected;
                } else if (tab == script_label) {
                    stack.set_visible_child_name ("scripting");
                    scripting_view.grab_focus ();
                    current_index = tabs.selected;
                }
            });
        }

        public void update_status (Models.Request request) {
            url_entry.change_status (request.status);
        }
    }
}
