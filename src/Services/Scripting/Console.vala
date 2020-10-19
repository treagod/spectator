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

namespace Spectator.Services.Scripting {
    namespace Console {
        public void register (Duktape.Context ctx) {
            var obj_idx = ctx.push_object ();
            ctx.push_vala_function (log, Duktape.VARARGS);
            ctx.put_prop_string (obj_idx, "log");
            ctx.push_vala_function (warning, Duktape.VARARGS);
            ctx.put_prop_string (obj_idx, "warning");
            ctx.push_vala_function (error, Duktape.VARARGS);
            ctx.put_prop_string (obj_idx, "error");
            ctx.put_global_string ("console");
        }

        private Duktape.ReturnType log (Duktape.Context ctx) {
            var writer = get_writer (ctx);
            ctx.push_string (" ");
            ctx.insert (0);
            ctx.join (ctx.get_top () - 1);
            writer.write ("%s".printf ( ctx.safe_to_string (-1)));

            return 0;
        }

        private Duktape.ReturnType warning (Duktape.Context ctx) {
            var writer = get_writer (ctx);
            ctx.push_string (" ");
            ctx.insert (0);
            ctx.join (ctx.get_top () - 1);
            writer.warning ("Warning: %s".printf ( ctx.safe_to_string (-1)));

            return 0;
        }

        private Duktape.ReturnType error (Duktape.Context ctx) {
            var writer = get_writer (ctx);
            ctx.push_string (" ");
            ctx.insert (0);
            ctx.join (ctx.get_top () - 1);
            writer.error ("Error: %s".printf ( ctx.safe_to_string (-1)));

            return 0;
        }
    }
}
