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

namespace Spectator.Widgets.Sidebar.Collection {
    public class Dropdown : Gtk.Box {
        public delegate void ItemIterator (RequestListItem item);
        private static string collection_open_icon = "folder-open";
        private static string collection_closed_icon = "folder";

        public signal void item_edit (Models.Request request);
        public signal void item_clone (Models.Request request);
        public signal void item_deleted (Models.Request request);
        public signal void request_item_selected (uint id);
        public signal void request_edit_clicked (uint id);
        public signal void request_clone_clicked (uint id);
        public signal void collection_delete ();
        public signal void collection_edit (Models.Collection collection);
        public signal void create_collection_request (uint id);

        public signal void change_visibility (bool visible);
        public signal void request_moved (uint target_id, uint moved_id);
        public signal void request_dropped (uint id);

        public uint collection_id { get; private set;}
        private Gtk.Label label;
        private Gtk.Box box;
        private Gtk.Box item_box;
        private Gtk.Image indicator;
        private Gtk.Revealer motion_revealer;
        private bool _expanded;
        public bool expanded {
            get {
                return this._expanded;
            }
            set {
                this._expanded = value;
                if (_expanded) {
                    indicator.set_from_icon_name (collection_open_icon, Gtk.IconSize.BUTTON);
                    item_box.show ();
                } else {
                    indicator.set_from_icon_name (collection_closed_icon, Gtk.IconSize.BUTTON);
                    item_box.hide ();
                }
            }
        }

        construct {
            orientation = Gtk.Orientation.VERTICAL;
            spacing = 0;
        }

        public void set_name (string name) {
            label.label = "<b>%s</b>".printf (name);
        }

        //TODO: fast abort (bool return or something)
        public void each_item (ItemIterator iter) {
            item_box.foreach ((it) => {
                var item = (RequestListItem) it;

                iter (item);
            });
        }

        public void unselect_all () {
            item_box.foreach ((it) => {
                var item = (RequestListItem) it;

                item.get_style_context ().remove_class ("active");
            });
        }

        public RequestListItem add_request (Models.Request request) {
            var request_list_item = new RequestListItem (request.id, request.name, request.uri, request.method);
            request_list_item.activate_drag_and_drop ();

            this.item_box.add (request_list_item);

            request_list_item.clicked.connect (() => {
                request_item_selected (request.id);
                this.request_item_selected (request.id);
            });

            request_list_item.edit_clicked.connect (() => {
                request_edit_clicked (request.id);
            });

            request_list_item.clone_clicked.connect (() => {
                request_clone_clicked (request.id);
            });

            request_list_item.request_appended.connect ((dropped_id) => {
                this.request_moved (request.id, dropped_id);
            });

            request_list_item.show_all();

            return request_list_item;
        }

        public Dropdown (Models.Collection collection) {
            this.collection_id = collection.id;
            this.box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 3);
            this.item_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 2);
            this.item_box.get_style_context ().add_class ("collection-items");
            this.label = new Gtk.Label ("<b>%s</b>".printf (collection.name));
            this.label.halign = Gtk.Align.START;
            this.label.use_markup = true;
            this.indicator = new Gtk.Image.from_icon_name (collection_open_icon, Gtk.IconSize.BUTTON);;
            this.expanded = true;

            var motion_grid = new Gtk.Grid ();
            motion_grid.margin = 6;
            motion_grid.get_style_context ().add_class ("grid-motion");

            this.motion_revealer = new Gtk.Revealer ();
            this.motion_revealer.transition_type = Gtk.RevealerTransitionType.SLIDE_RIGHT;
            this.motion_revealer.add (motion_grid);
            this.motion_revealer.height_request = 24;

            box.add (indicator);
            box.add (label);
            box.pack_end (motion_revealer, true, true);

            var event_box = create_event_box (collection);

            add (event_box);
            add (item_box);

            show_all ();
            item_box.hide ();
            this.build_drag_and_drop ();
        }

        private void build_drag_and_drop () {
            Gtk.drag_dest_set (this, Gtk.DestDefaults.ALL, TARGET_ENTRIES_LABEL, Gdk.DragAction.MOVE);
            this.drag_data_received.connect (on_drag_data_received);
            this.drag_motion.connect (on_drag_motion);
            this.drag_leave.connect (on_drag_leave);
        }

        private void on_drag_data_received (Gdk.DragContext context, int x, int y,
            Gtk.SelectionData selection_data, uint target_type, uint time) {
            var row = ((Gtk.Widget[]) selection_data.get_data ())[0];
            var source = (RequestListItem) row;

            this.request_dropped (source.id);
            this._expanded = true;
        }

        public bool on_drag_motion (Gdk.DragContext context, int x, int y, uint time) {
            this.motion_revealer.reveal_child = true;

            return true;
        }

        public void on_drag_leave (Gdk.DragContext context, uint time) {
            this.motion_revealer.reveal_child = false;
        }

        private Gtk.EventBox create_event_box (Models.Collection model) {
            var event_box = new Gtk.EventBox ();
            event_box.add (box);
            event_box.button_release_event.connect ((event) => {
                var result = false;
                switch (event.button) {
                    case 1:
                        expanded = !expanded;
                        this.change_visibility (expanded);
                        result = true;
                        break;
                    case 3:
                        var menu = new Gtk.Menu ();
                        var new_request_item = new Gtk.MenuItem.with_label (_("Add Request"));
                        var edit_item = new Gtk.MenuItem.with_label (_("Edit"));
                        var delete_item = new Gtk.MenuItem.with_label (_("Delete"));

                        new_request_item.activate.connect (() => {
                            create_collection_request (this.collection_id);
                        });

                        edit_item.activate.connect (() => {
                            collection_edit (model);
                        });

                        delete_item.activate.connect (() => {
                            collection_delete ();
                        });

                        menu.add (new_request_item);
                        menu.add (new Gtk.SeparatorMenuItem ());
                        menu.add (edit_item);
                        menu.add (delete_item);
                        menu.show_all ();
                        menu.popup_at_pointer (event);
                        result = true;
                        break;
                    default:
                        break;
                }

                return result;
            });

            return event_box;
        }
    }
}
