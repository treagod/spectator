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
    namespace Helper {
        private const string OBJ_TYPE = "_sot_"; // Spectator Object Type
        private const string OBJ_CONTENT = "_soc_"; // Spectator Object Content
        private const int URL_ENC_TYPE = 42;
        private const int FORM_DATA_TYPE = 1337;
        public void register (Duktape.Context ctx) {
            ctx.push_vala_function (url_encoded, 1);
            ctx.put_global_string ("UrlEncoded");

            ctx.push_vala_function (form_data, 1);
            ctx.put_global_string ("FormData");
        }

        private void create_helper_object (Duktape.Context ctx, int magic_number) {
            var obj_idx = ctx.push_object ();
            ctx.push_int (magic_number);
            ctx.put_prop_string (obj_idx, OBJ_TYPE);
            ctx.insert (-2);
            ctx.put_prop_string (-2, OBJ_CONTENT);
        }

        private Duktape.ReturnType url_encoded (Duktape.Context ctx) {
            if (!valid ("UrlEncoded", ctx)) return (Duktape.ReturnType) 0;

            create_helper_object (ctx, URL_ENC_TYPE);
            return (Duktape.ReturnType) 1;
        }

        public static Duktape.ReturnType form_data (Duktape.Context ctx) {
            if (!valid ("FormData", ctx)) return (Duktape.ReturnType) 0;

            create_helper_object (ctx, FORM_DATA_TYPE);
            return (Duktape.ReturnType) 1;
        }

        public static bool valid (string name, Duktape.Context ctx) {
            var writer = get_writer (ctx);
            if (!ctx.is_object (-1)) {
                writer.error ("'%s' only accepts a flat-object".printf (name));
                return false;
            }

            return true;
        }
    }
}
