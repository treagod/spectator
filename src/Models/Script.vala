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

namespace Spectator.Models {
    public class Script  {
        private Duktape.Context context;
        private bool evaluated;
        private string _code;

        public string code {
            public get {
                return _code;
            } public set {
                _code = value;
                evaluated = false;
            }
        }

        public Script () {
            code = "";
            evaluated = false;
            init_context ();
        }

        private void init_context () {
            context = new Duktape.Context ();
        }

        private void evaluate_code () {
            if (!evaluated) {
                if (context.peval_string (code) != 0) {
                    // error reporting
                }
                evaluated = true;
            }
        }

        public void execute (Models.Request request) {
            evaluate_code ();
            context.get_global_string ("before_sending");
            if (context.is_function(-1)) {
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
                context.call (1);
            } else {
                // error handling report_failing_call("request_sent");
            }
        }
    }
}
