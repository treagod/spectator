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
    public enum ConsoleMessageType {
        LOG,
        ERROR,
        WARNING
    }

    public class ScriptRunner : Object {
        public signal void console_output (string str, ConsoleMessageType mt);

        private weak ScriptContext main_context;
        private weak Models.Request request;
        private ScriptWriter writer;
        private int thread_id;
        private string error = "";

        public bool valid {
            get {
                return this.error.length == 0;
            }
        }

        public ScriptRunner (ScriptContext ctx, Models.Request request) {
            this.main_context = ctx;
            this.thread_id = this.main_context.push_thread ();
            this.writer = new BufferWriter ();

            this.request = request;
            this.eval_code ();
        }

        ~ScriptRunner () {
            this.main_context.remove (this.thread_id);
        }

        public void run_before_sending () {
            unowned var runner_context = create_runner_context ();
            runner_context.push_ref (writer);
            runner_context.put_global_string (Duktape.hidden_symbol ("writer"));


            writer.written.connect ((str) => {
                this.console_output (str, ConsoleMessageType.LOG);
            });

            writer.error_written.connect ((str) => {
                this.console_output (str, ConsoleMessageType.ERROR);
            });

            writer.warning_written.connect ((str) => {
                this.console_output (str, ConsoleMessageType.WARNING);
            });

            runner_context.get_global_string ("before_sending");
            if (runner_context.is_function (-1)) {
                runner_context.push_false ();
                runner_context.put_global_string (Duktape.hidden_symbol ("abort"));

                runner_context.push_request (request);

                if (runner_context.pcall (1) != 0) {
                    runner_context.get_global_string (Duktape.hidden_symbol ("abort"));
                    if (runner_context.get_boolean (-1)) {
                        runner_context.pop ();
                    } else {
                        runner_context.pop ();
                        if (runner_context.is_error (-1)) {
                            var err = runner_context.safe_to_string (-1);
                            runner_context.emit_error (err);
                            runner_context.pop ();
                        }
                    }
                }
            }
        }

        private void eval_code () {
            unowned var runner_context = create_runner_context ();

            if (runner_context.peval_string (this.request.script_code) != 0) {
                this.error = runner_context.safe_to_string (-1);
            }
        }

        private unowned ScriptContext create_runner_context () {
            return (ScriptContext) this.main_context.get_context (this.thread_id);
        }
    }

    public class ScriptRuntime : Object {
        private ScriptContext context;
        private ScriptWriter writer;

        public ScriptRuntime () {
            this.context = new ScriptContext ();

            Scripting.HTTP.register (this.context);
            Scripting.Console.register (this.context);
            Scripting.Helper.register (this.context);
        }

        public ScriptRunner get_runner (Models.Request request) {
            return new ScriptRunner (this.context, request);
        }
    }
}
