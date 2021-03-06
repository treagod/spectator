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

namespace Spectator.Repository {
    public class InMemoryEnvironment : IEnvironment, Object {
        private Gee.ArrayList<Models.Environment> envs;
        private int current_env;

        public InMemoryEnvironment () {
            envs = new Gee.ArrayList<Models.Environment> ();
            current_env = 0;
            var env = new Models.Environment ("My Environment");
            var v = new Models.Variable  ("id", "5");
            env.variables[v.id] = v;
            v = new Models.Variable  ("base_url", "http://localhost:3456");
            env.variables[v.id] = v;
            v = new Models.Variable  ("placeholder", "https://jsonplaceholder.typicode.com");
            env.variables[v.id] = v;
            envs.add (env);
            env = new Models.Environment ("Development");
            v = new Models.Variable  ("id", "5");
            env.variables[v.id] = v;
            envs.add (env);
            envs.add (new Models.Environment ("Woop"));
        }

        public override void delete_environment (string name) {}

        public void add_variable_to_environment (string env_name) {
            foreach (var env in envs) {
                if (env.name == env_name) {
                    var variable = new Models.Variable ("", "");
                    env.variables[variable.id] = variable;
                    return;
                }
            }
        }

        public void delete_variable_value_in_environment (Models.Environment env, string variable_id) {
            foreach (var e in envs) {
                if (e.name == env.name) {
                    e.variables.unset (variable_id);
                    return;
                }
            }
        }

        public Gee.ArrayList<Models.Environment> get_environments () {
            return envs;
        }

        public Models.Variable? get_variables_in_current_environment_by_name (string variable_name) {
            return get_variables_in_environment_by_name ("current_env", variable_name);
        }

        public Models.Variable? get_variables_in_environment_by_name (string env_name, string variable_name) {
            return new Models.Variable ("asd", "asd");
        }

        public Gee.ArrayList<Models.Variable> get_environment_variables (string env_name) {
            foreach (var env in envs) {
                if (env.name == env_name) {
                    var sorted_variables = new Gee.ArrayList<Models.Variable> ();
                    sorted_variables.add_all (env.variables.values);

                    sorted_variables.sort((a,b) => {
                        return a.created_at.compare (b.created_at);
                    });

                    return sorted_variables;
                }
            }
            return new Gee.ArrayList<Models.Variable> ();
        }

        public void update_variable_name_in_environment (Models.Environment env, string id, string key) {
            foreach (var e in envs) {
                if (e.name == env.name) {
                    e.variables[id].key = key;
                    return;
                }
            }
        }

        public void update_variable_value_in_environment (Models.Environment env, string id, string value) {
            foreach (var e in envs) {
                if (e.name == env.name) {
                    e.variables[id].val = value;
                    return;
                }
            }
        }

        public Models.Environment? get_environment_by_name (string name) {
            foreach (var env in envs) {
                if (env.name == name ) {
                    return env;
                }
            }

            return null;
        }

        public Models.Environment get_current_environment () {
            return envs.get (current_env);
        }

        public void set_current_environment (Models.Environment env) {
            for(int i = 0; i < envs.size; i++) {
                var e = envs.get (i);

                if (e.name == env.name) {
                    current_env = i;
                    break;
                }
            }
        }

        public void create_environment (string name) throws RecordExistsError {
            var env = new Models.Environment (name);

            foreach (var e in envs) {
                if (e.name == name) {
                    throw new RecordExistsError.CODE_1A (_("Environment name already exists"));
                }
            }

            envs.add (env);
        }
    }
}
