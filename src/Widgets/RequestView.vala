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
    class RequestView : Gtk.Box {
        private RequestItem item;
        private UrlEntry url_entry;
        private HeaderView header_view;

        public signal void item_changed(RequestItem item);
        public signal void response_received(ResponseItem it);

        construct {
            orientation = Gtk.Orientation.VERTICAL;
            margin = 4;
        }

        public RequestView () {
            url_entry = new UrlEntry ();
            header_view = new HeaderView ();
            url_entry.margin_bottom = 10;

            url_entry.url_changed.connect ((url) => {
                item.domain = url;
                item_changed (item);
            });

            url_entry.method_changed.connect ((method) => {
                item.method = method;
                item_changed (item);
            });

            url_entry.request_activated.connect (perform_request);

            var stack = new Gtk.Stack ();
            stack.margin = 6;
            stack.margin_bottom = 18;
            stack.margin_top = 18;
            var stack_switcher = new Gtk.StackSwitcher ();
            stack_switcher.set_stack (stack);
            stack_switcher.halign = Gtk.Align.CENTER;

            stack.add_titled (header_view, "header", _("Header"));
            stack.add_titled (new Gtk.Label ("12435243"), "url_params", _("URL Parameters"));
            stack.add_titled (new Gtk.Label ("12435243"), "body", _("Body"));
            stack.add_titled (new Gtk.Label ("12435243"),"Auth", "Auth");
            stack.add_titled (new Gtk.Label ("12435243"),"Options", "Options");

            add (url_entry);
            add (stack_switcher);
            add (stack);
        }

        public RequestItem get_item () {
            return item;
        }

        public void set_item (RequestItem ite) {
            item = ite;
            url_entry.item_status_changed (item.status);
            url_entry.set_text (item.domain);
            url_entry.set_method (item.method);
            header_view.update_item (item);
            show_all ();
        }

        private async void perform_request () {
            grab_focus ();
            ulong microseconds = 0;
            double seconds = 0.0;
            var url = item.domain;
            Timer timer = new Timer ();

            MainLoop loop = new MainLoop ();
            var session = new Soup.Session ();
            session.user_agent = item.user_agent;
            var msg = new Soup.Message ("GET", item.domain);

            foreach (var header in item.headers) {
                msg.request_headers.append (header.key, header.val);
            }

            session.queue_message (msg, (sess, mess) => {
                timer.stop ();
                var res = new ResponseItem ();
                seconds = timer.elapsed (out microseconds);
                res.duration = seconds;
                res.raw = (string) mess.response_body.data;
                res.status_code = mess.status_code;
                res.size = mess.response_body.length;
                res.url = url;
                mess.response_headers.foreach ((key, val) => {
                    res.add_header (key, val);
                });
                item.status = RequestStatus.SENT;
                item.response = res;
                response_received(res);
                url_entry.item_status_changed (item.status);
                loop.quit ();
	        });

	        item.status = RequestStatus.SENDING;
	        url_entry.item_status_changed (item.status);

	        url_entry.cancel_process.connect (() => {
                session.cancel_message (msg, Soup.Status.CANCELLED);
                item.status = RequestStatus.SENT;
                url_entry.item_status_changed (item.status);
            });
        }
    }
}
