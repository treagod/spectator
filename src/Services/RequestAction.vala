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
    public class RequestAction {
        private RequestItem item;
        private Settings settings = Settings.get_instance ();
        private uint performed_redirects = 0;
        private Timer? timer;

        public signal void finished_request ();

        public RequestAction(RequestItem it) {
            item = it;
        }

        public async void make_request () {
            timer = new Timer ();

            perform_request ();

	        item.status = RequestStatus.SENDING;
        }

        private async void perform_request (string? location = null) {
            ulong microseconds = 0;
            double seconds = 0.0;
            location = (location == null) ? item.domain : location;
            MainLoop loop = new MainLoop ();
            var session = new Soup.Session ();
            session.user_agent = item.user_agent;
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

            var msg = new Soup.Message (item.method.to_str (), location);

            foreach (var header in item.headers) {
                msg.request_headers.append (header.key, header.val);
            }

            session.queue_message (msg, (sess, mess) => {
                // Performance new request to redirected location
                if (mess.status_code == 301 && settings.follow_redirects /*&& settings.maximum_redirects < performed_redirects */) {
                    perform_request (mess.response_headers.get_one ("Location"));
                    return;
                }

                var res = new ResponseItem ();

                res.status_code = mess.status_code;
                res.size = mess.response_body.length;
                res.url = location;

                var builder = new StringBuilder ();

                mess.response_headers.foreach ((key, val) => {
                    res.add_header (key, val);
                    builder.append ("%s: %s\r\n".printf (key, val));
                });

                builder.append ("\r\n");
                builder.append ((string) mess.response_body.data);

                res.raw = builder.str;
                res.data = (string) mess.response_body.data;

                item.status = RequestStatus.SENT;
                item.response = res;
                timer.stop ();

                seconds = timer.elapsed (out microseconds);

                item.response.duration = seconds;

                finished_request ();
                loop.quit ();
	        });
        }
    }
}
