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

    public class Container : Gtk.Box {
        private Gtk.FlowBox item_box;
        private Gtk.ScrolledWindow scroll;

        public signal void item_deleted (RequestItem item);
        public signal void item_edited (RequestItem item);
        public signal void selection_changed (RequestItem item);
        public signal void notify_delete ();

        public Container () {
            scroll = new Gtk.ScrolledWindow (null, null);
            scroll.hscrollbar_policy = Gtk.PolicyType.AUTOMATIC;
            scroll.vscrollbar_policy = Gtk.PolicyType.AUTOMATIC;

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
                selection_changed (history_item.item);
            });

            orientation = Gtk.Orientation.VERTICAL;
            width_request = 265;

            scroll.add (item_box);

            this.pack_start (titlebar, false, true, 0);
            this.pack_start (scroll, true, true, 0);
        }

        public void update_active_method (Method method) {
            var sidebar_item = get_active ();

            if (sidebar_item != null) {
                sidebar_item.item.method = method;
            }
        }

        public void update_active_url (string uri) {
            var sidebar_item = get_active ();

            if (sidebar_item != null) {
                sidebar_item.item.uri = uri;
            }
        }

        public void add_item (RequestItem item) {
            var box_item = new Sidebar.Item (item);

            item_box.add (box_item);
            item_box.show_all ();
            item_box.select_child(box_item);

            box_item.item_deleted.connect ((item) => {
                item_deleted (item);
                item_box.remove (box_item);
            });

            box_item.item_edit.connect ((item) => {
                item_edited (item);
            });
        }

        public void update_active (RequestItem item) {
            Sidebar.Item? sidebar_item = get_active ();

            if (sidebar_item != null) {
                sidebar_item.update (item);
            }
        }

        private Sidebar.Item? get_active () {
            var children = item_box.get_selected_children ();

            if (children.length() > 0) {
                return ((Sidebar.Item) children.nth_data (0));
            }

            return null;
        }

        public RequestItem? get_active_item () {
            var sidebar_item = get_active ();

            if (sidebar_item != null) {
                return sidebar_item.item;
            }

            return null;
        }

        public void clear_selection () {
            item_box.unselect_all ();
            queue_draw ();
        }
    }
}
