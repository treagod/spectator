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

namespace Spectator.Widgets.Response {
    public enum CurrentView {
        None,
        JsonTreeView,
        PrettifiedSourceView,
        SourceView,
        XmlTreeView,
        WebkitView,
        HeaderView,
        CookiesView,
        InfoView
    }

    class Container : Gtk.Box {
        private StatusBar.Container status_bar;
        private ModeDropdown mode_dropdown;
        private Gtk.Stack stack;
        private HeaderList header_list;
        private Gtk.ScrolledWindow header_scroll;
        private HeaderList cookie_list;
        private Gtk.ScrolledWindow cookie_scroll;
        private ModeButton tabs;
        private SourceView source_view;
        private Gtk.ScrolledWindow text_scrolled;
        private SourceView plain_view;
        private Gtk.ScrolledWindow plain_scrolled;
        private JsonTreeView json_tree_view;
        private Gtk.ScrolledWindow json_scrolled;
        private XmlTreeView xml_tree_view;
        private Gtk.ScrolledWindow xml_scrolled;
        private CurrentView current_view;

        construct {
            orientation = Gtk.Orientation.VERTICAL;
            margin = 4;
        }

        private bool is_dropdown_view () {
            if (
                current_view == CurrentView.JsonTreeView ||
                current_view == CurrentView.PrettifiedSourceView ||
                current_view == CurrentView.XmlTreeView
            ) {
                return true;
            }
            return false;
        }

        public Container () {
            stack = new Gtk.Stack ();
            source_view = new SourceView ();
            text_scrolled = new Gtk.ScrolledWindow (null, null);
            text_scrolled.add (source_view);
            plain_view = new SourceView ();
            plain_scrolled = new Gtk.ScrolledWindow (null, null);
            plain_scrolled.add (plain_view);
            header_scroll = new Gtk.ScrolledWindow (null, null);
            header_list = new HeaderList ();
            header_scroll.add (header_list);
            cookie_scroll = new Gtk.ScrolledWindow (null, null);
            cookie_list = new HeaderList ();
            cookie_scroll.add (cookie_list);
            json_scrolled = new Gtk.ScrolledWindow (null, null);
            json_tree_view = new JsonTreeView.empty ();
            json_scrolled.add (json_tree_view);
            xml_scrolled = new Gtk.ScrolledWindow (null, null);
            xml_tree_view = new XmlTreeView.empty ();
            xml_scrolled.add (xml_tree_view);
            current_view = CurrentView.None;

            stack.add_named (text_scrolled, "prettified_view");
            stack.add_named (header_scroll, "headers");
            stack.add_named (cookie_scroll, "cookies");
            stack.add_named (json_scrolled, "json_tree_view");
            stack.add_named (xml_scrolled, "xml_tree_view");
            stack.add_named (plain_scrolled, "plain_view");
            stack.set_visible_child (json_scrolled);

            status_bar = new StatusBar.Container ();
            status_bar.halign = Gtk.Align.START;

            tabs = new ModeButton ();
            tabs.halign = Gtk.Align.CENTER;
            mode_dropdown = new ModeDropdown (stack);

            var locked = false;

            tabs.append_with_right_click_event (mode_dropdown, (event) => {
                if (is_dropdown_view ()) {
                    if (locked) {
                        locked = false;
                    } else {
                        mode_dropdown.dropdown ();
                    }
                }

                return true;
            });

            var header_label = new Gtk.Label ("Header");
            var cookie_label = new Gtk.Label ("Cookies");
            //var info_label = new Gtk.Label ("Info");
            tabs.append (header_label);
            tabs.append (cookie_label);
            //tabs.append (info_label);

            tabs.mode_changed.connect ((widget) => {
                if (widget == header_label) {
                    stack.set_visible_child (header_scroll);
                    current_view = CurrentView.HeaderView;
                } else if (widget == cookie_label) {
                    stack.set_visible_child (cookie_scroll);
                    current_view = CurrentView.CookiesView;
                } else if (widget == mode_dropdown) {
                    current_view = mode_dropdown.current_view;

                    switch (current_view) {
                        case CurrentView.JsonTreeView:
                        stack.set_visible_child (json_scrolled);
                        break;
                        case CurrentView.XmlTreeView:
                        stack.set_visible_child (xml_scrolled);
                        break;
                        case CurrentView.PrettifiedSourceView:
                        stack.set_visible_child (text_scrolled);
                        break;
                        default:
                        stack.set_visible_child (plain_scrolled);
                        break;
                    }
                    locked = true;
                }
            });

            pack_start (status_bar, false, false, 4);
            pack_start (tabs, false, false, 3);
            pack_start (stack);
            tabs.set_active (0);

            locked = false;
        }

        public void update (Models.Response response) {
            status_bar.update (response);
            header_list.clear ();
            cookie_list.clear ();

            if (response.headers.size == 0) {
                header_list.add_header ("No headers", "");
            } else {
                foreach (var header in response.headers.entries) {
                    header_list.add_header(header.key, header.value);
                }
            }

            if (response.cookies.size == 0) {
                cookie_list.add_header ("No cookies", "");
            } else {
                foreach (var cookie in response.cookies.entries) {
                    cookie_list.add_header (cookie.key, cookie.value);
                }
            }

            header_list.show_all ();
            cookie_list.show_all ();
            var content_type = response.headers["Content-Type"];

            if (is_json (content_type)) {
                json_tree_view.clear ();
                mode_dropdown.set_items (ModeDropdown.DropdownItems.Json);
                source_view.set_lang ("json");
                json_tree_view.update_from_string (response.data);
            } else if (is_html (content_type)) {
                mode_dropdown.set_items (ModeDropdown.DropdownItems.Html);
                source_view.set_lang ("html");
            } else if (is_xml (content_type)) {
                mode_dropdown.set_items (ModeDropdown.DropdownItems.Xml);
                xml_tree_view.clear ();
                xml_tree_view.update_from_string (response.data);
                source_view.set_lang ("xml");
            } else {
                mode_dropdown.set_items (ModeDropdown.DropdownItems.Other);
            }

            if (current_view != CurrentView.None) {
                mode_dropdown.current_view = current_view;

                switch (current_view) {
                case CurrentView.JsonTreeView:
                    stack.set_visible_child (json_scrolled);
                    tabs.set_active (0);
                    break;
                case CurrentView.XmlTreeView:
                    stack.set_visible_child (xml_scrolled);
                    tabs.set_active (0);
                    break;
                case CurrentView.PrettifiedSourceView:
                    stack.set_visible_child (text_scrolled);
                    tabs.set_active (0);
                    break;
                case CurrentView.HeaderView:
                    stack.set_visible_child (header_scroll);
                    tabs.set_active (1);
                    break;
                case CurrentView.CookiesView:
                    stack.set_visible_child (cookie_scroll);
                    tabs.set_active (2);
                    break;
                case CurrentView.SourceView:
                    stack.set_visible_child (plain_scrolled);
                    tabs.set_active (0);
                    break;
                default:
                    stack.set_visible_child (plain_scrolled);
                    break;
                }
            } else {
                if (is_json (content_type)) {
                    stack.set_visible_child (json_scrolled);
                    current_view = CurrentView.JsonTreeView;
                } else if (is_html (content_type)) {
                    stack.set_visible_child (text_scrolled);
                    current_view = CurrentView.PrettifiedSourceView;
                } else if (is_xml (content_type)) {
                    stack.set_visible_child (xml_scrolled);
                    current_view = CurrentView.XmlTreeView;
                } else {
                    stack.set_visible_child (plain_scrolled);
                    current_view = CurrentView.SourceView;
                }

                mode_dropdown.current_view = current_view;
                tabs.set_active (0);
            }

            source_view.buffer.text = response.data;
            plain_view.buffer.text = response.data;
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

