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
        private Gtk.ScrolledWindow scrolled;
        private ResponseStatusBar status_bar;
        private Gtk.Stack stack;
        private HtmlView html_view;

        construct {
            orientation = Gtk.Orientation.VERTICAL;
        }

        public ResponseView () {
            html_view = new HtmlView ();
            status_bar = new ResponseStatusBar ();

            status_bar.view_changed.connect ((i) => {
                html_view.show (i);
            });

            pack_start (status_bar, false, false, 15);
            pack_start (html_view);
        }

        public void update_response (ResponseItem? it) {
            if (it != null) {
                foreach (var entry in it.headers.entries) {
                    if (entry.key == "Content-Type") {
                        if (is_html (entry.value)) {
                            status_bar.set_active_type (ResponseType.HTML);
                        } else if (is_json (entry.value)) {
                            status_bar.set_active_type (ResponseType.JSON);
                        } else if (is_xml (entry.value)) {
                            status_bar.set_active_type (ResponseType.XML);
                        } else {
                            status_bar.set_active_type (ResponseType.UNKOWN);
                        }
                    }
                }
            } else {
                status_bar.set_active_type (ResponseType.UNKOWN);
            }
            status_bar.update (it);
            html_view.update (it);
            html_view.show (0);
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
