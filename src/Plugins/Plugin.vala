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

public static Duktape.ReturnType native_print (Duktape.Context ctx) {
    ctx.push_string (" ");
    ctx.insert (0);
    ctx.join (ctx.get_top () - 1);
    stdout.printf ("%s\n", ctx.safe_to_string (-1));

    return 0;
}

namespace HTTPInspector.Plugins {
    public class Plugin {
        private string source;
        private Duktape.Context context;
        public string? author;
        public string? name;
        public string? description;
        public string? version;

        public Plugin (string src_code, string json) {
            Utils.set_information (this, json);
            source = src_code;
            setup_context ();
            context.eval_string (source);
        }

        public void call_request_sent (RequestItem req) {
            context.get_global_string ("request_sent");
            var obj_idx = context.push_object ();
            context.push_string (req.name);
            context.put_prop_string (obj_idx, "name");
            context.push_string (req.uri);
            context.put_prop_string (obj_idx, "uri");
            context.push_string (req.method.to_str ());
            context.put_prop_string (obj_idx, "method");

            var header_obj = context.push_object ();
            foreach (var header in req.headers) {
                // TODO: If header already exists, append it
                context.push_string (header.val);
                context.put_prop_string (header_obj, header.key);
            }
            context.put_prop_string (obj_idx, "headers");
            context.call (1);
        }

        private void setup_context () {
            context = new Duktape.Context ();
            var obj_idx = context.push_object ();

            context.push_vala_function (native_print, Duktape.VARARGS);
            context.put_prop_string (obj_idx, "log");
            context.put_global_string ("console");

            obj_idx = context.push_object ();
            context.push_string (Constants.VERSION);
            context.put_prop_string (obj_idx, "version");
            context.put_global_string ("HttpInspector");

            setup_plugin_information ();
        }

        private void setup_plugin_information () {
            if (author != null) {
                context.push_string (author);
            } else {
                context.push_null ();
            }
            context.put_global_string ("author");
            if (name != null) {
                context.push_string (name);
                context.put_global_string ("name");
            }
            if (description != null) {
                context.push_string (description);
                context.put_global_string ("description");
            }
            if (version != null) {
                context.push_string (version);
                context.put_global_string ("version");
            }
        }
    }
}
