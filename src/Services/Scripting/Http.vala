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

namespace Spectator.Services.Scripting {
    namespace HTTP {
        public void register (Duktape.Context ctx) {
            var obj_idx = ctx.push_object ();
            ctx.push_vala_function (method_get, 2);
            ctx.put_prop_string (obj_idx, "get");
            ctx.push_vala_function (method_destroy, 2);
            ctx.put_prop_string (obj_idx, "destroy");
            ctx.push_vala_function (method_head, 2);
            ctx.put_prop_string (obj_idx, "head");
            ctx.push_vala_function (method_post, 2);
            ctx.put_prop_string (obj_idx, "post");
            ctx.push_vala_function (method_put, 2);
            ctx.put_prop_string (obj_idx, "put");
            ctx.push_vala_function (method_patch, 2);
            ctx.put_prop_string (obj_idx, "patch");
            ctx.put_global_string ("HTTP");
        }

        private Duktape.ReturnType method_get (Duktape.Context ctx) {
            return http_no_body (ctx, "GET");
        }

        private Duktape.ReturnType method_head (Duktape.Context ctx) {
            return http_no_body (ctx, "HEAD");
        }

        private Duktape.ReturnType method_destroy (Duktape.Context ctx) {
            return http_no_body (ctx, "DELETE");
        }

        public static void http_create_response_object (Duktape.Context ctx, Soup.Message msg) {
            var obj_idx = ctx.push_object ();
            ctx.push_int ((int) msg.status_code);
            ctx.put_prop_string (obj_idx, "status");
            var header_idx = ctx.push_object ();
            msg.response_headers.foreach ((key, val) => {
                ctx.push_string (val);
                ctx.put_prop_string (header_idx, key);
            });
            ctx.put_prop_string (obj_idx, "headers");
            ctx.push_string ((string) msg.response_body.data);
            ctx.put_prop_string (obj_idx, "data");
        }

        private static void handle_body_object (Duktape.Context ctx, Soup.Message msg) {
            ctx.get_prop_string (-1, Helper.obj_type);
            var type = 0;
            if (!ctx.is_undefined (-1) && ctx.is_number (-1)) {
                type = ctx.get_int (-1);
            }
            ctx.pop ();

            if (type == Helper.url_enc_type) {
                ctx.get_prop_string (-1, Helper.obj_content);
                var encoded = create_url_encoded_string (ctx);

                msg.set_request ("application/x-www-form-urlencoded", Soup.MemoryUse.COPY, encoded.data);
            } else if (type == Helper.form_data_type) {
                ctx.get_prop_string (-1, Helper.obj_content);
                append_multipart_to_message (ctx, msg);
            } else {
                msg.set_request ("application/json", Soup.MemoryUse.COPY, ctx.json_encode (-1).data);
            }

        }

        private void append_multipart_to_message (Duktape.Context ctx, Soup.Message msg) {
            var multipart = new Soup.Multipart ("multipart/form-data");

            ctx.enum (-1, 0);
            while (ctx.next (-1, true)) {
                if (ctx.is_string (-1) && ctx.is_string (-2)) {
                    multipart.append_form_string (ctx.get_string (-2), ctx.get_string (-1));
                }
                ctx.pop_n (2);
            }
            ctx.pop ();

            multipart.to_message (msg.request_headers, msg.request_body);
        }

        private static string create_url_encoded_string (Duktape.Context ctx) {
            var builder = new StringBuilder ();
            var first = true;
            ctx.enum (-1, 0);
            while (ctx.next (-1, true)) {
                if (ctx.is_string (-2) && (ctx.is_string (-1) || ctx.is_number (-1))) {
                    if (first) {
                        first = false;
                    } else {
                        builder.append ("&");
                    }

                    if (ctx.is_string (-1)) {
                        builder.append ("%s=%s".printf (
                            Soup.URI.encode (ctx.get_string (-2), "&"),
                            Soup.URI.encode (ctx.get_string (-1), "&")
                        ));
                    } else {
                        builder.append ("%s=%d".printf (
                            Soup.URI.encode (ctx.get_string (-2), "&"),
                            ctx.get_int (-1)
                        ));
                    }

                }

                ctx.pop_n (2);
            }
            ctx.pop ();

            return builder.str;
        }

        private void append_headers_to_msg (Duktape.Context ctx, Soup.Message msg) {
            ctx.get_prop_string (-1, "headers");
            if (!ctx.is_undefined (-1) && ctx.is_object (-1)) {
                ctx.enum (-1, 0);
                while (ctx.next (-1, true)) {
                    msg.request_headers.append (ctx.get_string (-2), ctx.get_string (-1));
                    ctx.pop_n (2);
                }
                ctx.pop ();
            }
            ctx.pop ();
        }

        private static void append_body_to_msg (Duktape.Context ctx, Soup.Message msg) {
            ctx.get_prop_string (-1, "body");
            if (!ctx.is_undefined (-1)) {
                if (ctx.is_string (-1)) {
                    var content_type = msg.request_headers.get_one ("Content-Type");
                    if (content_type != null) {
                        msg.set_request (content_type, Soup.MemoryUse.COPY, ctx.get_string (-1).data);
                    } else {
                        msg.set_request ("text/plain", Soup.MemoryUse.COPY, ctx.get_string (-1).data);
                    }
                } else if (ctx.is_object (-1)) {
                    handle_body_object (ctx, msg);
                } else {
                    var writer = get_writer (ctx);
                    writer.error ("Invalid 'body'. 'body' must be a string or an object");
                }
            }
            ctx.pop ();
        }

        public static void set_timeout (Duktape.Context ctx, Soup.Session session) {
            ctx.get_prop_string (-1, "timeout");
            if (!ctx.is_undefined (-1)) {
                if (ctx.is_string (-1)) {
                    uint64 result;
                    if (uint64.try_parse (ctx.get_string (-1), out result)) {
                        session.timeout = (uint) result;
                    } else {
                        session.timeout = 0;
                        var writer = get_writer (ctx);
                        writer.warning ("Invalid timeout paramter. Setting timeout to 0");
                    }
                } else if (ctx.is_number (-1)) {
                    session.timeout = ctx.get_int (-1);
                }
            }
            ctx.pop ();
        }

        public static Duktape.ReturnType method_patch (Duktape.Context ctx) {
            return http_body (ctx, "PATCH");
        }

        public static Duktape.ReturnType method_put (Duktape.Context ctx) {
            return http_body (ctx, "PUT");
        }

        public static Duktape.ReturnType method_post (Duktape.Context ctx) {
            return http_body (ctx, "POST");
        }

        public static Duktape.ReturnType http_no_body (Duktape.Context ctx, string method) {
            if (!ctx.is_string (-2)) return 0;

            var uri_string = ctx.get_string (-2);
            var uri = new Soup.URI (uri_string);

            if (Spectator.Services.Utilities.valid_uri (uri)) {
                var session = new Soup.Session ();
                var msg = new Soup.Message (method, uri_string);

                if (!ctx.is_undefined (-1) && ctx.is_object (-1)) {
                    append_headers_to_msg (ctx, msg);
                    set_timeout (ctx, session);
                }

                session.send_message (msg);

                http_create_response_object (ctx, msg);

                return (Duktape.ReturnType) 1;
            } else {
                var writer = get_writer (ctx);
                writer.error ("URL '%s' is not valid".printf (uri_string));
            }

            return 0;
        }


        public static Duktape.ReturnType http_body (Duktape.Context ctx, string method) {
            if (!ctx.is_string (-2)) return 0;

            var uri_string = ctx.get_string (-2);
            var uri = new Soup.URI (uri_string);

            if (Spectator.Services.Utilities.valid_uri (uri)) {
                var session = new Soup.Session ();
                var msg = new Soup.Message (method, uri_string);
                if (!ctx.is_undefined (-1) && ctx.is_object (-1)) {
                    append_headers_to_msg (ctx, msg);
                    append_body_to_msg (ctx, msg);
                    set_timeout (ctx, session);
                }

                session.send_message (msg);

                http_create_response_object (ctx, msg);

                return (Duktape.ReturnType) 1;
            }

            return 0;
        }
    }
}
