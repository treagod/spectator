/*
* Copyright (c) 2021 Marvin Ahlgrimm (https://github.com/treagod)
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
    public class ResolveResult {        
        public Gee.ArrayList<string> unresolved_variable_names { get; private set; }
        public string resolved_text { get; private set; }

        public ResolveResult (string text, Gee.ArrayList<string> errors) {
            resolved_text = text;
            unresolved_variable_names = errors;
        }

        public bool has_errors () {
            return unresolved_variable_names.size > 0;
        }
    }
    
    public class VariableResolver {
        weak Repository.IEnvironment environments;
        Regex variable_regex;

        public VariableResolver (Repository.IEnvironment envs) {
            environments = envs;
            try {
                variable_regex = new Regex("#{(.*)}", RegexCompileFlags.UNGREEDY); // Todo: Cache Regex
            } catch (RegexError error) {
                stderr.printf ("Unable to initialize regex\n");
                Process.exit(1);
            }
        }

        public ResolveResult? resolve_request_variables (ref Models.Request request) {
            var result = resolve_variables (request.uri);

            if (!result.has_errors ()) {
                request.uri = result.resolved_text;
            } else {
                return result;
            }

            return null;
        }

        public ResolveResult resolve_variables (string text) {
            try {
                var errors = new Gee.ArrayList<string> ();
                var resolved_text = variable_regex.replace_eval (text, text.length, 0, 0, (match_info, builder) => {
                    var variable_name = match_info.fetch (1);
                    var variable = environments.get_variables_in_current_environment_by_name (variable_name);
    
                    if (variable != null) {
                        builder.append (variable.val);
                    } else {
                        builder.append (variable_name);
                        errors.add (variable_name);
                    }
                    return false;
                });

                return new ResolveResult (resolved_text, errors);
            } catch (RegexError error) {
                var errors = new Gee.ArrayList<string> ();
                errors.add ("Could not parse text");
                var result = new ResolveResult ("", errors);
                
                return result;
            }
        }
    }
}