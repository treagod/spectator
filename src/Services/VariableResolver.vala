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
    public class VariableResolver {
        private weak Repository.IEnvironment environments;
        Regex variable_regex;

        public VariableResolver (Repository.IEnvironment envs) {
            environments = envs;
            try {
                variable_regex = new Regex("#{(.*)}", RegexCompileFlags.UNGREEDY);
            } catch (RegexError error) {
                stderr.printf ("Unable to initialize regex\n");
                Process.exit(1);
            }
        }

        public void resolve_request_variables (ref Models.Request request) {
            request.uri = resolve_variables (request.uri);
        }

        public string resolve_variables (string url) {
            // TODO: Refactor. Just proof of concept
            try {
                return variable_regex.replace_eval (url, url.length, 0, 0, (match_info, builder) => {
                    var current_environment = environments.get_current_environment ();
                    var variable_name = current_environment.get_variable (match_info.fetch (1));
    
                    if (variable_name != null) {
                        builder.append (variable_name);
                    } else {
                        builder.append ("UNDEF_VARIABLE");
                    }
                    return false;
                });
            } catch (RegexError error) {
                return "Could not parse URL";
            }
        }
    }
}