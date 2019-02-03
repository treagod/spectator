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

public static Duktape.ReturnType set_window_width (Duktape.Context ctx) {
    var width = ctx.get_int(-1);
    int height, _;
    ctx.get_global_string (Duktape.hidden_symbol("application_window"));
    unowned Gtk.ApplicationWindow window = ctx.get_pointer<Gtk.ApplicationWindow>(-1);

    window.get_size (out _, out height);
    window.resize(width, height);

    return 0;
}

public static Duktape.ReturnType set_window_height (Duktape.Context ctx) {
    var height = ctx.get_int(-1);
    int width, _;
    ctx.get_global_string (Duktape.hidden_symbol("application_window"));
    unowned Gtk.ApplicationWindow window = ctx.get_pointer<Gtk.ApplicationWindow>(-1);

    window.get_size (out width, out _);
    window.resize(width, height);

    return 0;
}

public static Duktape.ReturnType get_window_width (Duktape.Context ctx) {
    int width, _;
    ctx.get_global_string (Duktape.hidden_symbol("application_window"));
    unowned Gtk.ApplicationWindow window = ctx.get_pointer<Gtk.ApplicationWindow>(-1);

    window.get_size (out width, out _);

    ctx.push_int (width);

    return (Duktape.ReturnType) 1;
}

public static Duktape.ReturnType get_window_height (Duktape.Context ctx) {
    int height, _;
    ctx.get_global_string (Duktape.hidden_symbol("application_window"));
    unowned Gtk.ApplicationWindow window = ctx.get_pointer<Gtk.ApplicationWindow>(-1);

    window.get_size (out _, out height);

    ctx.push_int (height);

    return (Duktape.ReturnType) 1;
}

public static Duktape.ReturnType show_alert (Duktape.Context ctx) {
    var title = ctx.get_string (-2);
    var description = ctx.get_string (-1);
    ctx.get_global_string (Duktape.hidden_symbol("application_window"));
    unowned Gtk.ApplicationWindow window = ctx.get_pointer<Gtk.ApplicationWindow>(-1);

    var alert = new Spectator.Dialogs.Alert (window, title, description);

    alert.show_all();

    return (Duktape.ReturnType) 1;
}

public static Duktape.ReturnType get_window (Duktape.Context ctx) {
    var obj_idx = ctx.push_object ();

    ctx.push_vala_function (set_window_height, 1);
    ctx.put_prop_string (obj_idx, "set_height");

    ctx.push_vala_function (set_window_width, 1);
    ctx.put_prop_string (obj_idx, "set_width");

    ctx.push_vala_function (get_window_height, 0);
    ctx.put_prop_string (obj_idx, "get_height");

    ctx.push_vala_function (get_window_width, 0);
    ctx.put_prop_string (obj_idx, "get_width");

    return (Duktape.ReturnType) 1;
}

namespace Spectator.Plugins {
    public class Plugin {
        private string source;
        private unowned GtkWrapper wrapper;
        private Duktape.Context context;
        public string? author;
        public string? name;
        public string? description;
        public string? version;
        public bool valid { get; private set; }

        public Plugin (string src_code, string json, GtkWrapper wrap) {
            Utils.set_information (this, json);
            source = src_code;
            wrapper = wrap;
            setup_context ();
            valid = true;

            if (context.peval_string (source) != 0) {
                valid = false;
            }
        }

        public void call_request_sent (RequestItem req) {
            context.get_global_string ("request_sent");
            if (context.is_function(-1)) {
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
            } else {
                report_failing_call("request_sent");
            }
        }

        private void report_failing_call (string fn_name) {
            if (false) { // TODO: Implement JS-Debug Mode to show errors
                stdout.printf("Failed to call '%s' on plugin %s\n", fn_name, name);
            }
        }

        public void set_window(Gtk.Window window) {
            //
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
            context.push_vala_function (get_window, 0);
            context.put_prop_string (obj_idx, "get_window");
            context.push_vala_function (show_alert, 2);
            context.put_prop_string (obj_idx, "show_alert");
            context.put_global_string (Constants.RELEASE_NAME);

            context.push_ref (wrapper.window);
            context.put_global_string (Duktape.hidden_symbol("application_window"));

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

///------
/*
void concept_duk () {
    var context = new Duk.Context ();

    context.add_object ("my_obj", (obj) => {
        obj.add_int ("age", 23);
        obj.add_string ("firstname", "Marvin");
        obj.add_object ("address", (o) => {
            o.add_string ("street", "Whatever");
        });
    });

    context.register_function ("my_func", 2, (ctx) => {
        var arg1 = ctx.int_arg(0);
        var arg2 = ctx.int_arg(1);

        ctx.return_int (arg1 + arg2);
    });
}
*/
