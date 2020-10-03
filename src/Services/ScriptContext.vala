/*
* Copyright (c) 2020 Marvin Ahlgrimm (https://github.com/treagod)
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
            Scripting.HTTP.register (this);
            Scripting.Console.register (this);
            Scripting.Helper.register (this);
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

        public void emit_error (string err) {
            var writer = get_writer (this);
            writer.error (err);
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

    public unowned Spectator.Services.ScriptWriter get_writer (Duktape.Context ctx) {
        ctx.get_global_string (Duktape.hidden_symbol ("writer"));
        unowned Spectator.Services.ScriptWriter writer = ctx.get_pointer<Spectator.Services.ScriptWriter> (-1);
        ctx.pop ();
        return writer;
    }

    public unowned Spectator.Models.Request get_request (Duktape.Context ctx) {
        ctx.get_global_string (Duktape.hidden_symbol ("request"));
        unowned Spectator.Models.Request request = ctx.get_pointer<Spectator.Models.Request> (-1);
        ctx.pop ();
        return request;
    }

    public Duktape.ReturnType add_request_header (Duktape.Context ctx) {
        var request = get_request (ctx);

        if (ctx.is_string (-1) && ctx.is_string (-2)) {
            request.add_header (new Spectator.Header (ctx.get_string (-2), ctx.get_string (-1)));
        }
        return 0;
    }
}
