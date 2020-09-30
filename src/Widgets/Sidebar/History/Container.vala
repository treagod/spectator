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

namespace Spectator.Widgets.Sidebar.History {
    public class DateBox : Gtk.Box {
        public delegate void ItemIterator (RequestListItem item);
        private Gtk.Box items;
        construct {
            orientation = Gtk.Orientation.VERTICAL;
            margin = 3;
        }

        public DateBox (string date_string) {
            items = new Gtk.Box (Gtk.Orientation.VERTICAL, 5);
            var date_label = new Gtk.Label ("<b>%s</b>".printf (date_string));
            date_label.justify = Gtk.Justification.CENTER;
            date_label.use_markup = true;

            pack_start (date_label, true, true);
            pack_start (items, true, true);
            items.show_all ();
        }

        public void each_item (ItemIterator iter) {
            items.foreach ((it) => {
                var item = (RequestListItem) it;

                iter (item);
            });
        }

        public uint item_size () {
            return items.get_children ().length ();
        }

        public void unselect_all () {
            /* use this.each */
            items.foreach ((it) => {
                var item = (RequestListItem) it;

                item.get_style_context ().remove_class ("active");
            });
        }

        public void add_item (RequestListItem item) {
            items.add (item);
        }
    }

    public class Container : Gtk.Box {
        private Gee.HashMap<string, DateBox> boxes;
        private Spectator.Window window;

        /* Create Interface for History/Collection.Container ?? */
        public uint? active_id { get; private set; }
        private Gee.HashMap<uint, RequestListItem> request_items;

        public signal void request_item_selected (uint id);
        public signal void request_edit_clicked (uint id);
        public signal void request_delete_clicked (uint id);

        construct {
            orientation = Gtk.Orientation.VERTICAL;
            margin = 6;
            expand = false;
        }

        public Container (Spectator.Window window) {
            this.window = window;
            this.request_items = new Gee.HashMap<uint, RequestListItem> ();
            this.boxes = new Gee.HashMap<string, DateBox> ();
            get_style_context ().add_class ("history-box");
            Settings.get_instance ().theme_changed.connect (() => {
                foreach (var entry in boxes.entries) {
                    var date_box = entry.value;
                    date_box.each_item ((item) => {
                        item.repaint ();
                    });
                }
            });
        }

        public void show_items () {
            this.clear ();
            foreach (var request in this.window.request_service.get_requests ()) {
                if (request.last_sent != null) {
                    this.add_request (request);
                }
            }
        }

        /* Common function with Collection.Container */
        public void select_request (uint id) {
            if (this.request_items.has_key (id)) {
                if (this.active_id != null) {
                    this.request_items[this.active_id].get_style_context ().remove_class ("active");
                }

                var request_item = this.request_items[id];
                request_item.get_style_context ().add_class ("active");
                this.active_id = id;
            } else {
                if (this.active_id != null) {
                    this.request_items[this.active_id].get_style_context ().remove_class ("active");
                }
            }
        }

        private void add_history_item (string key_date, Models.Request request) {
            var request_list_item = new RequestListItem (request.id, request.name, request.uri, request.method);

            request_list_item.clicked.connect ((event) => {
                this.request_item_selected (request.id);
                this.select_request (request.id);
            });

            request_list_item.edit_clicked.connect (() => {
                this.request_edit_clicked (request.id);
            });

            request_list_item.delete_clicked.connect (() => {
                this.request_items.unset (request.id);
                this.request_delete_clicked (request.id);
            });

            if (boxes.has_key (key_date)) {
                var date_box = boxes[key_date];
                date_box.add_item (request_list_item);
                date_box.show_all ();
            } else {
                var date_box = new DateBox (key_date);
                date_box.add_item (request_list_item);
                boxes[key_date] = date_box;
                add (date_box);
                date_box.show_all ();
            }

            this.request_items[request.id] = request_list_item;
        }

        public void add_request (Models.Request request) {
            var now = new DateTime.now_local ();
            var difference = now.difference (request.last_sent);

            if (difference < 1 * TimeSpan.DAY) {
                add_history_item ("Today", request);
            } else if (difference >= 1 * TimeSpan.DAY && difference < 2 * TimeSpan.DAY) {
                add_history_item ("Yesterday", request);
            } else {
                add_history_item (request.last_sent.format ("%e. %B %Y"), request);
            }
        }

        public void clear () {
            @foreach ((widget) => {
                remove (widget);
            });
            boxes.clear ();
        }

        public void update (Gee.HashMap<Models.Request, DateTime> requests_history) {
            var now = new DateTime.now_local ();
            @foreach ((widget) => {
                remove (widget);
            });

            foreach (var entry in requests_history.entries) {
                var difference = now.difference (entry.value);

                if (difference < 1 * TimeSpan.DAY) {
                    add_history_item ("Today", entry.key);
                } else if (difference == 1 * TimeSpan.DAY) {
                    add_history_item ("Yesterday", entry.key);
                } else {
                    add_history_item (entry.value.format ("%e. %B %Y"), entry.key);
                }
            }
        }
    }
}
