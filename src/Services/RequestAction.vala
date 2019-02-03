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

namespace Spectator {
    public class RequestAction {
        private RequestItem item;
        private Settings settings = Settings.get_instance ();
        private Timer timer;
        private Soup.Session session;
        private MainLoop loop;
        private bool is_canceled;

        public signal void finished_request ();
        public signal void request_failed (RequestItem item);
        public signal void invalid_uri (RequestItem item);
        public signal void proxy_failed (RequestItem item);

        public RequestAction(RequestItem it) {
            item = it;
            session = new Soup.Session ();
            is_canceled = false;
        }

        public async void make_request () {
            timer = new Timer ();
            yield perform_request ();
	        item.status = RequestStatus.SENDING;
        }

        public RequestItem get_item () {
            return item;
        }

        public void cancel () {
            is_canceled = true;
            session.flush_queue ();
            session.abort ();
            loop.quit ();
        }

        private bool is_raw_type (RequestBody.ContentType type) {
            return type == RequestBody.ContentType.JSON ||
                   type == RequestBody.ContentType.XML ||
                   type == RequestBody.ContentType.HTML ||
                   type == RequestBody.ContentType.PLAIN;
        }

        private uint redirect_request (Soup.Message msg) {
            uint performed_redirects = 0;
            while (performed_redirects < settings.maximum_redirects) {
                performed_redirects += 1;
                var new_uri = new Soup.URI (msg.response_headers.get_one ("Location"));

                if (new_uri != null) {
                    msg.set_uri (new_uri);
                    session.send_message (msg);
                }
            }

            return performed_redirects;
        }

        private void read_response(Soup.Session sess, Soup.Message mess) {
            if (mess.response_body.data == null) {
                if (!is_canceled) {
                    request_failed (item);
                }
                return;
            }

            if (mess.status_code == 407) {
                if (settings.use_proxy) {
                    var auth_string = "";
                    if (settings.use_userinformation) {
                        auth_string = "%s:%s".printf (settings.proxy_username, settings.proxy_password);
                    } else {
                        // try to extract info from url string
                        var http_proxy = new Soup.URI (settings.http_proxy);
                        auth_string = "%s:%s".printf (http_proxy.get_user(), http_proxy.get_password ());
                    }
                    var auth_string_b64 = Base64.encode ((uchar[]) auth_string.to_utf8 ());
                    mess.request_headers.append ("Proxy-Authorization", "Basic %s".printf (auth_string_b64));
                    sess.send_message (mess);
                } else {
                    proxy_failed (item);
                }
            }

            var res = new ResponseItem ();
            res.url = item.uri;

            // Performance new request to redirected location
            if (mess.status_code == 302 && settings.follow_redirects) {
                res.redirects = redirect_request (mess);
            }

            res.status_code = mess.status_code;
            res.size = mess.response_body.length;

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

            ulong _;
            var seconds = timer.elapsed (out _);

            item.response.duration = seconds;

            finished_request ();
            loop.quit ();
        }

        private async void perform_request () {
            if (!item.has_valid_uri ()) {
                invalid_uri (item);
                return;
            }

            loop = new MainLoop ();

            session.timeout = (uint) settings.timeout;

            var method = item.method;

            var msg = new Soup.Message (method.to_str (), item.uri);

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

            var user_agent = "";
            var content_type_set = false;
            foreach (var header in item.headers) {
                if (header.key == "User-Agent") {
                    user_agent = header.val;
                    continue;
                }

                // TODO: better handling of user defined content type
                if (header.key == "Content-Type") {
                    content_type_set = true;
                    continue;
                }

                if (header.key == "")
                msg.request_headers.append (header.key, header.val);
            }

            if (method == Method.POST || method == Method.PUT || method == Method.PATCH) {
                var body = item.request_body;
                if (is_raw_type (body.type)) {
                    if (content_type_set) {
                        msg.set_request (null, Soup.MemoryUse.COPY, body.raw.data);
                    } else {
                        msg.set_request (RequestBody.ContentType.to_mime (body.type), Soup.MemoryUse.COPY, body.raw.data);
                    }
                } else if (body.type == RequestBody.ContentType.FORM_DATA) {
                    var multipart = new Soup.Multipart ("multipart/form-data");

                    // TODO: Support file upload
                    foreach (var pair in body.form_data) {
                        multipart.append_form_string (pair.key, pair.val);
                    }

                    multipart.to_message (msg.request_headers, msg.request_body);
                } else if (body.type == RequestBody.ContentType.URLENCODED) {
                    var builder = new StringBuilder ();
                    var first = true;
                    foreach (var pair in body.urlencoded) {
                        if (first) {
                            first = false;
                        } else {
                            builder.append ("&");
                        }
                        builder.append ("%s=%s".printf (
                            Soup.URI.encode(pair.key, "&"),
                            Soup.URI.encode(pair.val, "&")
                        ));
                    }
                    msg.set_request ("application/x-www-form-urlencoded", Soup.MemoryUse.COPY, builder.str.data);
                }
            }

            // Use applications User-Agent if none was defined
            if (user_agent == "") {
                session.user_agent = "%s-%s".printf (Constants.RELEASE_NAME, Constants.VERSION);
            } else {
                session.user_agent = user_agent;
            }

            session.queue_message (msg, read_response);
        }
    }
}
