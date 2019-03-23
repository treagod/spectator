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
    [Compact]
    public class ScriptContext : Duktape.Context {
        public ScriptContext (ScriptWriter writer) {
            push_ref (writer);
            put_global_string (Duktape.hidden_symbol ("writer"));
        }

        public void set_writer (ScriptWriter writer) {
            push_ref (writer);
            put_global_string (Duktape.hidden_symbol ("writer"));
        }

        public void push_request (Models.Request request) {
            push_ref (request);
            put_global_string (Duktape.hidden_symbol ("request"));

            var obj_idx = push_object ();
            push_string (request.name);
            put_prop_string (obj_idx, "name");
            push_string (request.uri);
            put_prop_string (obj_idx, "uri");
            push_string (request.method.to_str ());
            put_prop_string (obj_idx, "method");

            var header_obj = push_object ();
            foreach (var header in request.headers) {
                push_string (header.val);
                put_prop_string (header_obj, header.key);
            }
            put_prop_string (obj_idx, "headers");
            push_vala_function (add_request_header, 2);
            put_prop_string (obj_idx, "add_header");
            push_vala_function (abort_request, 0);
            put_prop_string (obj_idx, "abort");
        }

        public void push_http_object () {
            var obj_idx = push_object ();
            push_vala_function (http_get, 2);
            put_prop_string (obj_idx, "get");
            push_vala_function (http_delete, 2);
            put_prop_string (obj_idx, "destroy");
            push_vala_function (http_head, 2);
            put_prop_string (obj_idx, "head");
            push_vala_function (http_post, 2);
            put_prop_string (obj_idx, "post");
            push_vala_function (http_put, 2);
            put_prop_string (obj_idx, "put");
            push_vala_function (http_patch, 2);
            put_prop_string (obj_idx, "patch");
            put_global_string ("HTTP");

            obj_idx = push_object ();
            push_vala_function (console_log, Duktape.VARARGS);
            put_prop_string (obj_idx, "log");
            put_global_string ("console");
        }

        public void push_content_type_object () {
            var obj_idx = push_object ();
            push_string ("json");
            put_prop_string (obj_idx, "Json");
            push_string ("form_data");
            put_prop_string (obj_idx, "FormData");
            push_string ("encoded");
            put_prop_string (obj_idx, "UrlEncoded");
            put_global_string ("ContentType");
        }
    }

    public static Duktape.ReturnType console_log (Duktape.Context ctx) {
        var writer = get_writer (ctx);
        ctx.push_string (" ");
        ctx.insert (0);
        ctx.join (ctx.get_top () - 1);
        writer.write ("%s".printf ( ctx.safe_to_string (-1)));

        return 0;
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
        ctx.get_prop_string(-1, "type");
        var type = "";
        if (!ctx.is_undefined (-1) && ctx.is_string (-1)) {
            type = ctx.get_string (-1);
        }
        ctx.pop ();
        ctx.get_prop_string(-1, "data");
        if (!ctx.is_undefined (-1) && ctx.is_object (-1)) {
            if (type == "json") {
                msg.set_request ("application/json", Soup.MemoryUse.COPY, ctx.json_encode (-1).data);
            } else if (type == "form_data") {
                append_multipart_to_message (ctx, msg);
            } else if (type == "encoded") {
                var encoded = create_url_encoded_string (ctx);

                msg.set_request ("application/x-www-form-urlencoded", Soup.MemoryUse.COPY, encoded.data);
            }
        }
        ctx.pop ();
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
        ctx.pop();

        multipart.to_message (msg.request_headers, msg.request_body);
    }

    private static string create_url_encoded_string (Duktape.Context ctx) {
        var builder = new StringBuilder ();
        var first = true;
        ctx.enum (-1, 0);
        while (ctx.next (-1, true)) {
            if (ctx.is_string (-1) && ctx.is_string (-2)) {
                if (first) {
                    first = false;
                } else {
                    builder.append ("&");
                }
                builder.append ("%s=%s".printf (
                    Soup.URI.encode(ctx.get_string (-2), "&"),
                    Soup.URI.encode(ctx.get_string (-1), "&")
                ));
            }

            ctx.pop_n (2);
        }
        ctx.pop();

        return builder.str;
    }

    private void append_headers_to_msg (Duktape.Context ctx, Soup.Message msg) {
        ctx.get_prop_string(-1, "headers");
        if (!ctx.is_undefined (-1) && ctx.is_object (-1)) {
            ctx.enum (-1, 0);
            while (ctx.next (-1, true)) {
                msg.request_headers.append (ctx.get_string (-2), ctx.get_string (-1));
                ctx.pop_n (2);
            }
            ctx.pop();
        }
        ctx.pop();
    }

    private static void append_body_to_msg (Duktape.Context ctx, Soup.Message msg) {
        if (ctx.is_object (-1)) {
            ctx.get_prop_string(-1, "body");
            if (!ctx.is_undefined (-1)) {
                if (ctx.is_string (-1)) {
                    msg.set_request ("undefined", Soup.MemoryUse.COPY, ctx.get_string (-1).data);
                } else if (ctx.is_object (-1)) {
                    handle_body_object (ctx, msg);
                }
            }
            ctx.pop();
        }
    }

    public static Duktape.ReturnType http_patch (Duktape.Context ctx) {
        return http_body (ctx, "PATCH");
    }

    public static Duktape.ReturnType http_put (Duktape.Context ctx) {
        return http_body (ctx, "PUT");
    }

    public static Duktape.ReturnType http_post (Duktape.Context ctx) {
        return http_body (ctx, "POST");
    }

    public static Duktape.ReturnType http_get (Duktape.Context ctx) {
        return http_no_body (ctx, "GET");
    }

    public static Duktape.ReturnType http_head (Duktape.Context ctx) {
        return http_no_body (ctx, "HEAD");
    }

    public static Duktape.ReturnType http_delete (Duktape.Context ctx) {
        return http_no_body (ctx, "DELETE");
    }

    public static Duktape.ReturnType http_no_body (Duktape.Context ctx, string method) {
        if (!ctx.is_string (-2)) return 0;

        var uri_string = ctx.get_string (-2);
        var uri = new Soup.URI (uri_string);

        if (Spectator.Services.Utilities.valid_uri (uri)) {
            var session = new Soup.Session ();
            var msg = new Soup.Message (method, uri_string);
            if (ctx.is_object (-1)) {
                append_headers_to_msg (ctx, msg);
            }

            session.send_message (msg);

            http_create_response_object (ctx, msg);

            return (Duktape.ReturnType) 1;
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
            append_headers_to_msg (ctx, msg);
            append_body_to_msg (ctx, msg);

            session.send_message (msg);

            http_create_response_object (ctx, msg);

            return (Duktape.ReturnType) 1;
        }

        return 0;
    }

    public unowned Spectator.Services.ScriptWriter get_writer (Duktape.Context ctx) {
        ctx.get_global_string (Duktape.hidden_symbol("writer"));
        unowned Spectator.Services.ScriptWriter writer = ctx.get_pointer<Spectator.Services.ScriptWriter>(-1);
        ctx.pop();
        return writer;
    }

    public unowned Spectator.Models.Request get_request (Duktape.Context ctx) {
        ctx.get_global_string (Duktape.hidden_symbol("request"));
        unowned Spectator.Models.Request request = ctx.get_pointer<Spectator.Models.Request>(-1);
        ctx.pop();
        return request;
    }

    public Duktape.ReturnType add_request_header (Duktape.Context ctx) {
        var request = get_request (ctx);

        if (ctx.is_string (-1) && ctx.is_string (-2)) {
            request.add_header (new Spectator.Pair(ctx.get_string (-2), ctx.get_string (-1)));
        }
        return 0;
    }
}
