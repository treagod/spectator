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

            stdout.printf ("%d\n", selected_item_idx);

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
            stdout.printf("Selected %d\n", idx);

            if (idx == -1) {
                stdout.printf ("Invalid itme\n");
            }

            selected_item = item;
            selected_item_idx = idx;

            foreach (var view in views) {
                view.selected_item_updated ();
            }
        }

        private async void perform_request () {
            ulong microseconds = 0;
            double seconds = 0.0;
            var url = selected_item.domain;
            Timer timer = new Timer ();

            MainLoop loop = new MainLoop ();
            var session = new Soup.Session ();
            session.user_agent = selected_item.user_agent;
            var msg = new Soup.Message ("GET", selected_item.domain);

            foreach (var header in selected_item.headers) {
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
                selected_item.status = RequestStatus.SENT;
                selected_item.response = res;
                //response_received(res);
                loop.quit ();
	        });

	        selected_item.status = RequestStatus.SENDING;
        }
    }
}
