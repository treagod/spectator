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

namespace Spectator.Services {
    public class RequestAction {
        public Models.Request request { get; private set; }
        public Models.Response response;
        private Settings settings = Settings.get_instance ();
        private Timer timer;
        private Soup.Session session;
        private bool is_canceled;
        private ScriptRunner script_runner;

        public signal void finished_request (Models.Response response);
        public signal void script_log (string log);
        public signal void request_got_chunk (Models.Response response);
        public signal void request_failed (Models.Request item);
        public signal void proxy_failed (Models.Request item);
        public signal void aborted ();


        public RequestAction (Models.Request req, ScriptRunner runner) {
            this.request = req;
            this.script_runner = runner;
            this.response = new Models.Response ();
            this.session = new Soup.Session ();
            this.is_canceled = false;
        }

        public async void make_request () {
            yield perform_request ();
        }

        public void cancel () {
            is_canceled = true;
            session.flush_queue ();
            session.abort ();
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

        private void read_response (Soup.Session sess, Soup.Message mess) {
            if (mess.response_body.data == null) {
                if (!is_canceled) {
                    request_failed (this.request);
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
                        auth_string = "%s:%s".printf (http_proxy.get_user (), http_proxy.get_password ());
                    }
                    var auth_string_b64 = Base64.encode ((uchar[]) auth_string.to_utf8 ());
                    mess.request_headers.append ("Proxy-Authorization", "Basic %s".printf (auth_string_b64));
                    sess.send_message (mess);
                } else {
                    proxy_failed (this.request);
                }
            }

            var res = new Models.Response ();
            res.url = request.uri;

            // Performance new request to redirected location
            if (mess.status_code == 302 && settings.follow_redirects) {
                res.redirects = redirect_request (mess);
            }

            res.status_code = mess.status_code;
            res.size = mess.response_body.length;

            var builder = new StringBuilder ();
            var http_version = mess.http_version == Soup.HTTPVersion.@1_0 ? "HTTP/1.0"
                                                                          : "HTTP/1.1";

            builder.append ("%s %u %s\r\n".printf (http_version,
                                                   res.status_code,
                                                   Soup.Status.get_phrase (res.status_code)));

            mess.response_headers.foreach ((key, val) => {
                res.add_header (key, val);
                builder.append ("%s: %s\r\n".printf (key, val));
            });

            builder.append ("\r\n");
            var body_data = (string) mess.response_body.data;
            builder.append (body_data);

            res.raw = builder.str;
            res.data = body_data;

            timer.stop ();

            ulong _;
            var seconds = timer.elapsed (out _);

            res.duration = seconds;

            this.finished_request (res);
        }

        private async void perform_request () {
            session.timeout = (uint) settings.timeout;

            var method = this.request.method;

            var msg = new Soup.Message (method.to_str (), this.request.uri);

            msg.got_headers.connect (() => {
                var is_chunked = false;
                var builder = new StringBuilder ();

                msg.response_headers.foreach ((name, val) => {
                    if (name == "Transfer-Encoding" && val == "chunked") {
                        is_chunked = true;

                        msg.response_headers.foreach ((key, val) => {
                            this.response.add_header (key, val);
                            builder.append ("%s: %s\r\n".printf (key, val));
                        });
                        builder.append ("\r\n");
                        this.response.status_code = msg.status_code;
                        this.response.data = "";
                    }
                });

                if (is_chunked) {
                    msg.got_chunk.connect ((chunk) => {
                        var tmp = (string) chunk.data;
                        tmp = tmp.substring (0, ((int) chunk.length));

                        this.response.data += tmp;
                        builder.append (tmp);
                        this.response.raw = builder.str;
                        this.response.size += chunk.length;
                        ulong _;
                        var seconds = timer.elapsed (out _);

                        this.response.duration = seconds;
                        request_got_chunk (this.response);
                    });
                }
            });

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
            var content_type = "";

            foreach (var header in this.request.headers) {
                if (header.key == "User-Agent") {
                    user_agent = header.val;
                    continue;
                }

                // TODO: better handling of user defined content type
                if (header.key == "Content-Type") {
                    content_type = header.val;
                    continue;
                }

                if (header.key == "") continue;
                msg.request_headers.append (header.key, header.val);
            }

            var body = this.request.request_body;
                if (is_raw_type (body.type)) {
                    // If a content type was set, use this content type
                    // Otherwise try to infer it from the body type
                    if (content_type.strip ().length > 0) {
                        msg.set_request (content_type, Soup.MemoryUse.COPY, body.content.data);
                    } else {
                        msg.set_request (RequestBody.ContentType.to_mime (body.type),
                                         Soup.MemoryUse.COPY, body.content.data);
                    }
                } else if (body.type == RequestBody.ContentType.FORM_DATA) {
                    var multipart = new Soup.Multipart ("multipart/form-data");

                    // TODO: Support file upload
                    foreach (var pair in body.get_as_form_data ()) {
                        multipart.append_form_string (pair.key, pair.val);
                    }

                    multipart.to_message (msg.request_headers, msg.request_body);
                } else if (body.type == RequestBody.ContentType.URLENCODED) {
                    var builder = new StringBuilder ();
                    var first = true;
                    foreach (var pair in body.get_as_urlencoded ()) {
                        if (first) {
                            first = false;
                        } else {
                            builder.append ("&");
                        }
                        builder.append ("%s=%s".printf (
                            Soup.URI.encode (pair.key, "&"),
                            Soup.URI.encode (pair.val, "&")
                        ));
                    }
                    msg.set_request ("application/x-www-form-urlencoded", Soup.MemoryUse.COPY, builder.str.data);
                }

            // Use applications User-Agent if none was defined
            if (user_agent == "") {
                session.user_agent = "%s-%s".printf (Constants.RELEASE_NAME, Constants.VERSION);
            } else {
                session.user_agent = user_agent;
            }


            if (script_runner.valid) {
                script_runner.run_before_sending ();
            }
            timer = new Timer ();
            session.queue_message (msg, read_response);
        }
    }
}
