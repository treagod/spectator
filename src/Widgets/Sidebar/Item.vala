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

namespace Spectator.Widgets.Sidebar {
    public class RequestListItem : Gtk.FlowBoxChild {
        static string no_url = "<small><i>" + (_("No URL specified")) + "</i></small>";
        private Gtk.EventBox item_box { get; set;}
        private Gtk.Label method;
        private Gtk.Label request_name;
        private Gtk.Label url;
        private Gtk.Revealer motion_revealer;
        private Gtk.Revealer content;
        public uint id { get; private set; }

        public signal void clicked ();
        public signal void delete_clicked ();
        public signal void edit_clicked ();
        public signal void clone_clicked ();

        public signal void request_appended (uint dropped_id);

        private string get_method_label (Models.Method method) {
            var dark_theme = Gtk.Settings.get_default ().gtk_application_prefer_dark_theme;
            switch (method) {
                case Models.Method.GET:
                    var color = dark_theme ? "64baff" : "0d52bf";
                    return "<span color=\"#" + color + "\">GET</span>";
                case Models.Method.POST:
                    var color = dark_theme ? "9bdb4d" : "3a9104";
                    return "<span color=\"#" + color + "\">POST</span>";
                case Models.Method.PUT:
                    var color = dark_theme ? "ffe16b" : "ad5f00";
                    return "<span color=\"#" + color + "\">PUT</span>";
                case Models.Method.PATCH:
                    var color = dark_theme ? "ffa154" : "cc3b02";
                    return "<span color=\"#" + color + "\">PATCH</span>";
                case Models.Method.DELETE:
                    var color = dark_theme ? "ed5353" : "a10705";
                    return "<span color=\"#" + color + "\">DELETE</span>";
                case Models.Method.HEAD:
                    var color = dark_theme ? "ad65d6" : "4c158a";
                    return "<span color=\"#" + color + "\">HEAD</span>";
                default:
                    assert_not_reached ();
            }
        }

        public RequestListItem (uint id, string name, string request_url, Models.Method request_method) {
            this.id = id;
            item_box = new Gtk.EventBox ();
            var info_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);

            request_name = new Gtk.Label (name);
            request_name.halign = Gtk.Align.START;
            request_name.ellipsize = Pango.EllipsizeMode.END;

            url = new Gtk.Label ("");
            url.halign = Gtk.Align.START;
            url.use_markup = true;
            url.ellipsize = Pango.EllipsizeMode.END;

            set_formatted_uri (request_url);

            info_box.add (request_name);
            info_box.add (url);
            info_box.has_tooltip = true;

            info_box.query_tooltip.connect ((x, y, keyboard_tooltip, tooltip) => {
                if (url.label == "") {
                    return false;
                }
                tooltip.set_markup (url.label);
                return true;
            });

            create_box_menu ();

            method = new Gtk.Label (get_method_label (request_method));
            method.set_justify (Gtk.Justification.CENTER);
            method.halign = Gtk.Align.END;
            method.get_style_context ().add_class ("sidebar-item-method");
            method.margin_end = 10;
            method.use_markup = true;

            var container = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
            container.margin = 4;

            container.pack_start (info_box, true, true, 0);
            container.pack_end (method, true, true, 2);

            /* Todo: Reorder widgets */
            var motion_grid = new Gtk.Grid ();
            motion_grid.margin = 6;
            motion_grid.get_style_context ().add_class ("grid-motion");
            motion_grid.height_request = 18;

            motion_revealer = new Gtk.Revealer ();
            motion_revealer.transition_type = Gtk.RevealerTransitionType.SLIDE_DOWN;
            motion_revealer.add (motion_grid);

            var revealer_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
            revealer_box.add (container);
            revealer_box.add (motion_revealer);

            content = new Gtk.Revealer ();
            content.reveal_child = true;
            content.transition_type = Gtk.RevealerTransitionType.SLIDE_DOWN;
            item_box.add (revealer_box);

            content.add (item_box);

            this.add (content);
        }

        public void activate_drag_and_drop () {
            Gtk.drag_source_set (
                this,
                Gdk.ModifierType.BUTTON1_MASK,
                TARGET_ENTRIES_LABEL,
                Gdk.DragAction.MOVE
            );

            this.drag_begin.connect (on_drag_begin);
            this.drag_data_get.connect (on_drag_data_get);

            // Make this widget a DnD destination.
            Gtk.drag_dest_set (
                this,
                Gtk.DestDefaults.MOTION | Gtk.DestDefaults.DROP,
                TARGET_ENTRIES_LABEL,
                Gdk.DragAction.MOVE
            );

            drag_motion.connect (on_drag_motion);
            drag_leave.connect (on_drag_leave);
            drag_end.connect (clear_indicator);
            drag_data_received.connect (on_data_received);
        }

        private void on_data_received (Gdk.DragContext context, int x, int y,
            Gtk.SelectionData selection_data, uint target_type, uint time) {

            var row = ((Gtk.Widget[]) selection_data.get_data ())[0];
            var source = (RequestListItem) row;

            this.request_appended (source.id);
        }


        private void on_drag_begin (Gtk.Widget widget, Gdk.DragContext context) {
            var row = (RequestListItem) widget;

            Gtk.Allocation alloc;
            row.get_allocation (out alloc);

            var surface = new Cairo.ImageSurface (Cairo.Format.ARGB32, alloc.width, alloc.height);
            var cr = new Cairo.Context (surface);
            cr.set_source_rgba (0, 0, 0, 0.3);
            cr.set_line_width (1);

            cr.move_to (0, 0);
            cr.line_to (alloc.width, 0);
            cr.line_to (alloc.width, alloc.height);
            cr.line_to (0, alloc.height);
            cr.line_to (0, 0);
            cr.stroke ();

            cr.set_source_rgba (255, 255, 255, 0.5);
            cr.rectangle (0, 0, alloc.width, alloc.height);
            cr.fill ();

            row.draw (cr);
            Gtk.drag_set_icon_surface (context, surface);
            content.reveal_child = false;
        }

        private void on_drag_data_get (Gtk.Widget widget, Gdk.DragContext context,
            Gtk.SelectionData selection_data, uint target_type, uint time) {
            uchar[] data = new uchar[(sizeof (RequestListItem))];
            ((Gtk.Widget[])data)[0] = widget;

            /* TODO: only id? */
            selection_data.set (
                Gdk.Atom.intern_static_string ("REQUEST"), 32, data
            );
        }

        public bool on_drag_motion (Gdk.DragContext context, int x, int y, uint time) {
            motion_revealer.reveal_child = true;

            return true;
        }

        public void on_drag_leave (Gdk.DragContext context, uint time) {
            motion_revealer.reveal_child = false;
            //  should_scroll = false;
        }

        public void clear_indicator (Gdk.DragContext context) {
            content.reveal_child = true;
        }

        public void set_url (string request_url) {
            set_formatted_uri (request_url);
            show_all ();
        }

        public void set_method (Models.Method m) {
            method.label = get_method_label (m);
            show_all ();
        }

        public void repaint () {
            var idx = method.label.index_of (">");
            var substr = method.label.substring(idx + 1);
            var method_str = substr.split ("<")[0];
            method.label = get_method_label (Models.Method.convert_from_string (method_str));
            show_all ();
        }

        private void set_formatted_uri (string request_url) {
            if (request_url.length > 0) {
                url.label = "<small><i>" + escape_url (request_url) + "</i></small>";
            } else {
                url.label = no_url;
            }
        }

        private void create_box_menu () {
            this.item_box.button_release_event.connect ((event) => {
                var result = false;
                switch (event.button) {
                    case 1:
                        result = true;
                        this.clicked ();
                        break;
                    case 3:
                        var menu = new Gtk.Menu ();
                        var edit_item = new Gtk.MenuItem.with_label (_("Edit"));
                        var clone_item = new Gtk.MenuItem.with_label (_("Clone"));
                        var delete_item = new Gtk.MenuItem.with_label (_("Delete"));

                        edit_item.activate.connect (() => {
                            this.edit_clicked ();
                        });

                        clone_item.activate.connect (() => {
                            this.clone_clicked ();
                        });

                        delete_item.activate.connect (() => {
                            this.delete_clicked ();
                        });

                        menu.add (edit_item);
                        menu.add (clone_item);
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
        }

        private string escape_url (string url) {
            var escaped_url = url;
            escaped_url = escaped_url.replace ("&", "&amp;");
            escaped_url = escaped_url.replace ("\"", "&quot;");
            escaped_url = escaped_url.replace ("<", "&lt;");
            escaped_url = escaped_url.replace (">", "&gt;");
            return escaped_url;
        }
    }
}
