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
    class ResponseView : Gtk.Box {
        private ResponseStatusBar status_bar;
        private AbstractTypeView html_view;
        private AbstractTypeView json_view;
        private Gtk.Stack stack;
        private ResponseItem? item;

        construct {
            orientation = Gtk.Orientation.VERTICAL;
        }

        public ResponseView () {
            stack = new Gtk.Stack ();
            html_view = new HtmlView ();
            json_view = new JsonView ();

            stack.add_named (html_view, "html_view");
            stack.add_named (json_view, "json_view");
            stack.set_visible_child (html_view);

            status_bar = new ResponseStatusBar ();

            status_bar.view_changed.connect ((i) => {
                var current_view = (AbstractTypeView) stack.get_visible_child ();
                current_view.show_view (i);
            });

            pack_start (status_bar, false, false, 15);
            pack_start (stack);
        }

        public void update (ResponseItem? it) {
            item = it;
            set_content_type (it);
            update_view (it);
            status_bar.update (it);
            var current_view = (AbstractTypeView) stack.get_visible_child ();
            current_view.update (it);
            current_view.show_view (0);
        }

        private void update_view (ResponseItem? it) {
            if (it == null) {
                stack.set_visible_child (json_view);
                return;
            }

            var content_type = it.headers["Content-Type"];

            if (is_html (content_type)) {
                stack.set_visible_child (html_view);
            } else if (is_json (content_type)) {
                stack.set_visible_child (json_view);
            } else if (is_xml (content_type)) {
                stack.set_visible_child (html_view);
            }
        }

        private void set_content_type (ResponseItem? it) {
            if (it == null) {
                status_bar.set_active_type (ResponseType.UNKOWN);
                return;
            }

            var content_type = it.headers["Content-Type"];
            if (content_type != null) {
                if (is_html (content_type)) {
                    status_bar.set_active_type (ResponseType.HTML);
                } else if (is_json (content_type)) {
                    status_bar.set_active_type (ResponseType.JSON);
                } else if (is_xml (content_type)) {
                    status_bar.set_active_type (ResponseType.XML);
                } else {
                    status_bar.set_active_type (ResponseType.UNKOWN);
                }
            }
        }

        private bool is_html (string type) {
            return type.contains ("text/html");
        }

        private bool is_json (string type) {
            return type.contains ("application/json") ||
                   type.contains ("text/json") ||
                   type.contains ("application/x-javascript") ||
                   type.contains ("text/x-javascript") ||
                   type.contains ("application/x-json") ||
                   type.contains ("text/x-json");
        }

        private bool is_xml (string type) {
            return type.contains ("text/xml") ||
                   type.contains ("application/xhtml+xml") ||
                   type.contains ("application/xml") ||
                   type.contains ("+xml");
        }
    }
}
