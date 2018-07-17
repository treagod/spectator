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
    public class RequestController {
        private List<View.Request> views;
        private RequestStore store;
        public RequestItem selected_item { get; private set; }
        private int selected_item_idx;

        public RequestController () {
            store = new RequestStore ();
            views = new List<View.Request> ();
        }

        public void add_request (RequestItem item) {
            store.add_request (item);
            selected_item = item;
            selected_item_idx = store.index_of (item);

            foreach (var view in views) {
                view.new_item (item);
                view.selected_item_updated ();
            }
        }

        public int get_selected_item_idx () {
            return selected_item_idx;
        }

        public void register_view (View.Request view) {
            views.append (view);
        }

        public void update_selected_item (RequestItem item) {
            var idx = store.index_of (item);

            if (idx == -1) {
                stdout.printf ("Invalid itme\n");
            }

            selected_item = item;
            selected_item_idx = idx;

            foreach (var view in views) {
                view.selected_item_updated ();
            }
        }

        public async void perform_request (string? location = null) {
            ulong microseconds = 0;
            double seconds = 0.0;
            var url = selected_item.domain;
            var settings = Settings.get_instance ();
            Timer timer = new Timer ();

            location = (location == null) ? selected_item.domain : location;

            MainLoop loop = new MainLoop ();
            var session = new Soup.Session ();
            session.user_agent = selected_item.user_agent;
            session.timeout = int.parse (settings.timeout);

            if (settings.use_proxy) {
                var no_proxies = settings.no_proxy.split (",");

                foreach (var no_proxy in no_proxies) {
                    if (no_proxy == location) {
                        break;
                    }
                }

                session.proxy_uri = new Soup.URI (settings.proxy_uri);
            }

            var msg = new Soup.Message ("GET", location);

            foreach (var header in selected_item.headers) {
                msg.request_headers.append (header.key, header.val);
            }

            session.queue_message (msg, (sess, mess) => {
                timer.stop ();

                // Performance new request to redirected location
                if (mess.status_code == 301 && settings.follow_redirects) {
                    perform_request (mess.response_headers.get_one ("Location"));
                    return;
                }

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
                selected_item.status = RequestStatus.SENT;
                selected_item.response = res;

                foreach (var view in views) {
                    view.request_completed ();
                }


                loop.quit ();
	        });

	        selected_item.status = RequestStatus.SENDING;
        }
    }
}
