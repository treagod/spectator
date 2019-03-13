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

public Duktape.ReturnType add_request_header (Duktape.Context ctx) {
    ctx.get_global_string (Duktape.hidden_symbol("request"));
    unowned Spectator.Models.Request request = ctx.get_pointer<Spectator.Models.Request>(-1);
    ctx.pop();

    if (request == null) return 0;

    if (ctx.is_string (-1) && ctx.is_string (-2)) {
        stdout.printf ("asdasd\n");
        request.add_header (new Spectator.Pair(ctx.get_string (-2), ctx.get_string (-1)));
    }
    return 0;
}

public static Duktape.ReturnType http_get (Duktape.Context ctx) {
    if (!ctx.is_string (-2)) return 0;

    var uri_string = ctx.get_string (-2);

    var session = new Soup.Session ();
    var uri = new Soup.URI (uri_string);

    if (uri != null) {
        var msg = new Soup.Message ("GET", uri_string);
        if (ctx.is_object (-1)) {
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

        session.send_message (msg);

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

        return (Duktape.ReturnType) 1;
    }


    return 0;
}

public static Duktape.ReturnType http_post (Duktape.Context ctx) {
    if (!ctx.is_string (-2)) return 0;

    var uri_string = ctx.get_string (-2);

    var session = new Soup.Session ();
    var uri = new Soup.URI (uri_string);

    if (uri != null) {
        var msg = new Soup.Message ("POST", uri_string);
        if (ctx.is_object (-1)) {
            ctx.get_prop_string(-1, "headers");
            if (!ctx.is_undefined (-1) && ctx.is_object (-1)) {
                ctx.enum (-1, 0);
                while (ctx.next (-1, true)) {
                    msg.request_headers.append (ctx.get_string (-1), ctx.get_string (-2));
                    ctx.pop_n (2);
                }
                ctx.pop();
            }
            ctx.pop();

            ctx.get_prop_string(-1, "body");
            if (!ctx.is_undefined (-1) && ctx.is_string (-1)) {
                msg.set_request ("undefined", Soup.MemoryUse.COPY, ctx.get_string (-1).data);
            }
            ctx.pop();
        }

        session.send_message (msg);

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

        return (Duktape.ReturnType) 1;
    }


    return 0;
}

namespace Spectator.Models {
    public class Script  {
        private Duktape.Context context;
        private bool evaluated;
        private bool _valid;
        private string _code;

        public  bool valid {
            get {
                if (!evaluated) {
                    evaluate_code ();
                }

                return _valid;
            } private set{
                _valid = value;
            }
        }

        public string code {
            public get {
                return _code;
            } public set {
                _code = value;
                evaluated = false;
            }
        }

        public Script () {
            init ();
        }

        public Script.with_code (string c) {
            init ();
            code = c;
        }

        private void init () {
            valid = true;
            code = "";
            evaluated = false;
            init_context ();
            create_http_object ();
        }

        private void create_http_object () {
            var obj_idx = context.push_object ();
            context.push_vala_function (http_get, 2);
            context.put_prop_string (obj_idx, "get");
            context.push_vala_function (http_post, 2);
            context.put_prop_string (obj_idx, "post");
            context.push_vala_function (native_print, Duktape.VARARGS);
            context.put_prop_string (obj_idx, "print"); // Only for debugging
            context.put_global_string ("HTTP");
        }

        private void init_context () {
            context = new Duktape.Context ();
        }

        private void evaluate_code () {
            if (!evaluated) {
                valid = context.peval_string (code) == 0;
                evaluated = true;
            }
        }

        public void execute (Models.Request request) {
            evaluate_code ();
            context.get_global_string ("before_sending");
            if (context.is_function(-1)) {
                context.push_ref (request);
                context.put_global_string (Duktape.hidden_symbol("request"));

                var obj_idx = context.push_object ();
                context.push_string (request.name);
                context.put_prop_string (obj_idx, "name");
                context.push_string (request.uri);
                context.put_prop_string (obj_idx, "uri");
                context.push_string (request.method.to_str ());
                context.put_prop_string (obj_idx, "method");

                var header_obj = context.push_object ();
                foreach (var header in request.headers) {
                    // TODO: If header already exists, append it
                    context.push_string (header.val);
                    context.put_prop_string (header_obj, header.key);
                }
                context.put_prop_string (obj_idx, "headers");
                context.push_vala_function (add_request_header, 2);
                context.put_prop_string (obj_idx, "add_header");
                context.call (1);
                context.pop ();
            }
        }
    }
}
