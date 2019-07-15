/*
* Copyright (c) 2019 Marvin Ahlgrimm (https://github.com/treagod)
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

namespace Spectator.Widgets.Sidebar {
    public class TitleBar : Gtk.Box {
        private Gtk.Label title;
        public string title_text {
            get {
                return title.label;
            }
            set {
                title.label = value;
            }
        }

        public TitleBar (string text) {
            orientation = Gtk.Orientation.VERTICAL;

            title = new Gtk.Label (text);
            title.get_style_context ().add_class ("h2");
            title.halign = Gtk.Align.CENTER;
            title.margin = 5;

            var separator = new Gtk.Separator (Gtk.Orientation.HORIZONTAL);
            separator.margin_top = 2;

            pack_start (title, true, true, 0);
            pack_start (separator, true, true, 0);
        }
    }

    public class Container : Gtk.Box {
        private Gtk.ScrolledWindow scroll;
        private string collection_title_text = _("Collections");
        private string history_title_text = _("History");
        private Gtk.Stack stack;
        public Collection.Container collection;
        public History.Container history;

        public signal void item_deleted (Models.Request item);
        public signal void item_edited (Models.Request item);
        public signal void selection_changed (Models.Request item);
        public signal void notify_delete ();
        public signal void create_collection_request (Models.Collection collection);
        public signal void collection_edit (Models.Collection collection);

        public Container () {
            scroll = new Gtk.ScrolledWindow (null, null);
            scroll.hscrollbar_policy = Gtk.PolicyType.AUTOMATIC;
            scroll.vscrollbar_policy = Gtk.PolicyType.AUTOMATIC;

            var titlebar = new TitleBar (collection_title_text);


            //  Settings.get_instance ().theme_changed.connect (() => {
            //      item_box.forall ((widget) => {
            //          var it = (Sidebar.Item) widget;
            //          it.update (it.item);
            //      });
            //  });

            orientation = Gtk.Orientation.VERTICAL;
            width_request = 265;

            collection = new Collection.Container ();
            history = new History.Container ();

            history.child_activated.connect ((child) => {
                var sidebar_item = child as Sidebar.Item;
                selection_changed (sidebar_item.item);
            });


            scroll.add (history);

            collection.item_edit.connect ((request) => {
                item_edited (request);
            });

            collection.item_deleted.connect ((request) => {
                item_deleted (request);
            });

            collection.item_clicked.connect ((item) => {
                selection_changed (item.item);
                history.change_active (item.item);
            });

            history.item_clicked.connect ((item) => {
                selection_changed (item.item);
                collection.change_active (item.item);
            });

            collection.create_collection_request.connect ((collection) => {
                create_collection_request (collection);
            });

            collection.collection_edit.connect ((collection) => {
                collection_edit (collection);
            });

            stack = new Gtk.Stack ();
            stack.add_named (collection, "groups");
            stack.add_named (scroll, "history");

            stack.set_visible_child (collection);

            var mode_buttons = create_mode_buttons ();

            mode_buttons.mode_changed.connect (() => {
                if (mode_buttons.selected == 0) {
                    stack.set_visible_child (collection);
                    titlebar.title_text = collection_title_text;
                } else {
                    stack.set_visible_child (scroll);
                    titlebar.title_text = history_title_text;
                }
            });

            mode_buttons.get_style_context ().add_class ("square");

            pack_start (titlebar, false, true, 0);
            pack_start (stack, true, true, 0);
            pack_end (mode_buttons, false, true, 0);
        }

        public void add_collection (Models.Collection model) {
            collection.add_collection (model);
        }

        private Granite.Widgets.ModeButton create_mode_buttons () {
            var mode = new Granite.Widgets.ModeButton ();
            mode.append_icon ("view-list-symbolic", Gtk.IconSize.SMALL_TOOLBAR);
            mode.append_icon ("document-open-recent-symbolic", Gtk.IconSize.SMALL_TOOLBAR);
            mode.set_active (0);

            return mode;
        }

        public void update_active_method (Models.Method method) {
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

        public void update_collection (Models.Collection col) {
            collection.update (col);
        }

        public void adjust_visibility () {
            collection.adjust_visibility ();
        }

        public void update_active (Models.Request item) {
            Sidebar.Item? sidebar_item = get_active ();

            if (sidebar_item != null) {
                sidebar_item.update (item);
            }
        }

        private Sidebar.Item? get_active () {
            var children = history.get_selected_children ();

            if (children.length () > 0) {
                return ((Sidebar.Item) children.nth_data (0));
            }

            return null;
        }

        public Models.Request? get_active_item () {
            var sidebar_item = get_active ();

            if (sidebar_item != null) {
                return sidebar_item.item;
            }

            return null;
        }

        public void clear_selection () {
            history.unselect_all ();
            queue_draw ();
        }
    }
}
