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

public Duktape.ReturnType abort_request (Duktape.Context ctx) {
    ctx.push_true ();
    ctx.put_global_string (Duktape.hidden_symbol("abort"));
    return (Duktape.ReturnType) (-1);
}

namespace Spectator.Models {
    public class Script  {
        public signal void script_error (string err);

        private Services.ScriptContext context;
        private bool evaluated;
        private bool _valid;
        private string _code;
        private Services.ScriptWriter writer;

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

        public void set_writer (Services.ScriptWriter wri) {
            writer = wri;
            context.set_writer (writer);
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
            writer = new Services.StdoutWriter ();
            context = new Services.ScriptContext (writer);
            context.push_http_object ();
            context.push_content_type_object ();
        }

        private void evaluate_code () {
            if (!evaluated) {
                valid = context.peval_string (code) == 0;
                evaluated = true;

                if (!valid) {
                    var err = context.safe_to_string (-1);
                    script_error (err);
                }

                context.pop (); // pops error string
            }
        }

        public bool execute_before_sending (Models.Request request) {
            evaluate_code ();
            if (valid) {
                context.get_global_string ("before_sending");
                if (context.is_function(-1)) {
                    context.push_false ();
                    context.put_global_string (Duktape.hidden_symbol("abort"));

                    context.push_request (request);

                    if (context.pcall (1) != 0) {
                        context.get_global_string (Duktape.hidden_symbol("abort"));
                        if (context.get_boolean (-1)) {
                            return false;
                        } else  {
                            if (context.is_error (-1)) {
                                var err = context.safe_to_string (-1);
                                script_error (err);
                                context.pop ();
                            }
                        }

                        valid = false;
                    }
                }
            }

            return true;
        }
    }
}
