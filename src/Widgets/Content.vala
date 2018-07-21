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
    class Content : Gtk.Stack, View.Request {
        private Granite.Widgets.Welcome welcome;
        private RequestResponsePane req_res_pane;

        public signal void item_changed (RequestItem item);
        public signal void welcome_activated(int index);

        public Content (RequestController req_ctrl) {
            req_ctrl.register_view (this);

            welcome = new Granite.Widgets.Welcome (_("HTTP Inspector"), _("Inspect your HTTP transmissions to the web"));
            welcome.hexpand = true;
            welcome.append ("bookmark-new", _("Create Request"), _("Create a new request to the web."));

            welcome.activated.connect((index) => {
                welcome_activated (index);
            });

            req_res_pane = new RequestResponsePane (req_ctrl);

            add_named (welcome, "welcome");
            add_named (req_res_pane, "req_res_pane");

            set_visible_child (welcome);

            show_all ();
        }

        public void show_request_view (RequestItem item) {
            req_res_pane.set_item (item);
            set_visible_child (req_res_pane);
        }

        public void show_welcome () {
            set_visible_child (welcome);
        }
    }

}	
