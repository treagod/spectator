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

namespace HTTPInspector.Widgets.Response {
    public class HtmlView : AbstractTypeView {
        private WebKit.WebView web_view;
        private SourceView response_text;
        private Gtk.ScrolledWindow scrolled;

        public HtmlView () {
            scrolled = new Gtk.ScrolledWindow (null, null);
            web_view = new WebKit.WebView ();
            response_text = new SourceView ();
            web_view.load_plain_text ("");
            scrolled.add (response_text);

            add_named (web_view, "web_view");
            add_named (scrolled, "response_text");

            set_visible_child (web_view);

            show_all ();
        }

        public override void show_view (int i) {
            switch (i) {
                case 1:
                    set_visible_child (scrolled);
                    break;
                default:
                    set_visible_child (web_view);
                    break;
            }
        }

        public override void update (ResponseItem? it) {
            if (it != null) {
                web_view.load_alternate_html (it.data, it.url, it.url);
            } else {
                web_view.load_plain_text ("");
            }


            response_text.insert (it);
        }
    }
}
