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

namespace HTTPInspector.Widgets.Sidebar {
    public class TitleBar : Gtk.Box {
        public TitleBar (string text) {
            orientation = Gtk.Orientation.HORIZONTAL;

            var title = new Gtk.Label (text);
            title.get_style_context ().add_class ("h3");
            title.halign = Gtk.Align.START;
            title.margin = 4;

            pack_start (title, true, true, 0);
        }
    }

    public class Container : Gtk.Box, View.Request {
        private Gtk.FlowBox item_box;
        private Gtk.ScrolledWindow scroll;
        private signal bool item_deleted (RequestItem item);
        public signal void item_edit (RequestItem item);

        public Container (RequestController req_ctrl) {
            req_ctrl.register_view (this);
            scroll = new Gtk.ScrolledWindow (null, null);
            scroll.hscrollbar_policy = Gtk.PolicyType.AUTOMATIC;
            scroll.vscrollbar_policy = Gtk.PolicyType.AUTOMATIC;

            selected_item_updated.connect (() => {
                update_active (req_ctrl.selected_item);
            });

            item_deleted.connect ((item) => {
                return req_ctrl.destroy (item);
            });

            new_item.connect ((item) => {
                append_request (item);
            });

            var titlebar = new TitleBar (_("Request History"));

            item_box = new Gtk.FlowBox ();
            item_box.activate_on_single_click = true;
            item_box.valign = Gtk.Align.START;
            item_box.min_children_per_line = 1;
            item_box.max_children_per_line = 1;
            item_box.selection_mode = Gtk.SelectionMode.SINGLE;
            item_box.margin = 6;
            item_box.expand = false;

            Settings.get_instance ().theme_changed.connect (() => {
                item_box.forall ((widget) => {
                    var it = (Sidebar.Item) widget;
                    it.update (it.item);
                });
            });

            item_box.child_activated.connect ((child) => {
                var history_item = child as Sidebar.Item;
                req_ctrl.update_selected_item (history_item.item);
            });

            orientation = Gtk.Orientation.VERTICAL;
            width_request = 265;

            scroll.add (item_box);

            this.pack_start (titlebar, false, true, 0);
            this.pack_start (scroll, true, true, 0);
        }

        public void update_active (RequestItem item) {
            item_box.get_selected_children ().foreach ((child) => {
                var history_item = child as Sidebar.Item;
                history_item.update (item);
            });
        }

        public void clear_selection () {
            item_box.unselect_all ();
            queue_draw ();
        }

        private void append_request (RequestItem item) {
            var box_item = new Sidebar.Item (item);

            item_box.add (box_item);
            item_box.show_all ();
            item_box.select_child(box_item);

            box_item.item_deleted.connect ((item) => {
                var deleted = item_deleted (item);

                if (deleted) {
                    item_box.remove (box_item);
                } else {
                    stderr.printf ("Something went wrong\n");
                }
            });

            box_item.item_edit.connect ((item) => {
                item_edit (item);

                item.notify.connect (() => {
                    box_item.refresh ();
                });
            });
        }
    }
}
