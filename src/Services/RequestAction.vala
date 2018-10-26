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
        public signal void request_failed (RequestItem item);

        public RequestAction(RequestItem it) {
            item = it;
        }

        public async void make_request () {
            timer = new Timer ();
            yield perform_request ();
	        item.status = RequestStatus.SENDING;
        }

        private async void perform_request (string? location = null) {
            ulong microseconds = 0;
            double seconds = 0.0;
            location = (location == null) ? item.uri : location;
            MainLoop loop = new MainLoop ();
            var session = new Soup.Session ();

            if (settings.use_proxy) {
                var proxy_resolver = new SimpleProxyResolver (null, null);

                // Workaround as no proxy setting in constructor is broken
                var ignore_hosts = settings.no_proxy.split (",");
                foreach (var host in ignore_hosts) {
                    host.strip ();
                }
                proxy_resolver.ignore_hosts = ignore_hosts;

                var http_proxy = settings.http_proxy;
                var https_proxy = settings.https_proxy;

                proxy_resolver.set_uri_proxy ("http", http_proxy);
                proxy_resolver.set_uri_proxy ("https", https_proxy);

                session.proxy_resolver = proxy_resolver;
            }

            session.timeout = (uint) settings.timeout;

            var msg = new Soup.Message (item.method.to_str (), location);

            var user_agent = "";
            foreach (var header in item.headers) {
                if (header.key == "User-Agent") {
                    user_agent = header.val;
                    continue;
                }
                msg.request_headers.append (header.key, header.val);
            }

            // Use applications User-Agent if none was defined
            if (user_agent == "") {
                session.user_agent = "HTTPInspector-%s".printf (Constants.VERSION);
            } else {
                session.user_agent = user_agent;
            }

            session.queue_message (msg, (sess, mess) => {
                if (mess.response_body.data == null) {
                    request_failed (item);
                    return;
                }
                // Performance new request to redirected location
                if (mess.status_code == 302 && settings.follow_redirects && performed_redirects < settings.maximum_redirects) {
                    performed_redirects += 1;
                    perform_request.begin (mess.response_headers.get_one ("Location"));
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
