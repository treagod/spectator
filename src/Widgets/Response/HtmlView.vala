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

namespace Spectator.Widgets.Response {
    public class HtmlView : AbstractTypeView {
        private WebKit.WebView web_view;
        private SourceView response_text;
        private Gtk.ScrolledWindow scrolled;
        private HeaderList header_list;
        private Gtk.ScrolledWindow header_scrolled;

        public HtmlView () {
            scrolled = new Gtk.ScrolledWindow (null, null);
            header_list = new HeaderList ();
            header_scrolled = new Gtk.ScrolledWindow (null, null);

            header_scrolled.add (header_list);

            var settings = Settings.get_instance ();

            if (settings.use_proxy) {
                var context = WebKit.WebContext.get_default ();
                var proxy_settings = new WebKit.NetworkProxySettings ("", settings.no_proxy.split (","));
                proxy_settings.add_proxy_for_scheme ("http", settings.http_proxy);
                proxy_settings.add_proxy_for_scheme ("https", settings.https_proxy);
                context.set_network_proxy_settings (WebKit.NetworkProxyMode.CUSTOM, proxy_settings);

                web_view = new WebKit.WebView.with_context (context);
            } else {
                web_view = new WebKit.WebView ();
            }

            configure_webview ();
            response_text = new SourceView ();
            web_view.load_plain_text ("");
            scrolled.add (response_text);

            add (web_view);
            add (scrolled);
            add (header_scrolled);

            set_visible_child (web_view);

            show_all ();
        }

        private void configure_webview () {
            var settings = web_view.get_settings ();
            settings.allow_file_access_from_file_urls = false;
            settings.allow_modal_dialogs = false;
            settings.enable_fullscreen = false;
            settings.enable_developer_extras = false;
            settings.enable_html5_database = false;
            settings.enable_html5_local_storage = false;
            settings.enable_java = false;
            settings.enable_page_cache = false;
            settings.enable_plugins = false;
            settings.enable_smooth_scrolling = true;
            settings.javascript_can_access_clipboard = false;
            settings.javascript_can_open_windows_automatically = false;
            web_view.editable = false;
        }

        public override void show_view (int i) {
            switch (i) {
                case 1:
                    set_visible_child (scrolled);
                    break;
                case 2:
                    set_visible_child (header_scrolled);
                    break;
                default:
                    set_visible_child (web_view);
                    break;
            }
        }

        public override void update (ResponseItem? it) {
            header_list.clear ();
            if (it != null) {
                web_view.load_html (it.data, it.url);
            } else {
                web_view.load_plain_text ("");
            }

            foreach (var entry in it.headers.entries) {
                header_list.add_header (entry.key, entry.value);
            }

            header_list.show_all ();

            response_text.insert (it);
        }
    }
}
