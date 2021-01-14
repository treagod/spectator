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
        
        public InMemoryEnvironment () {
            envs = new Gee.ArrayList<Models.Environment> ();
            var env = new Models.Environment ("My Environment");
            env.variables["id"] = "5";
            env.variables["base_url"] = "http://localhost:3456";
            env.variables["placeholder"] = "https://jsonplaceholder.typicode.com";
            envs.add (env);
            envs.add (new Models.Environment ("Development"));
            envs.add (new Models.Environment ("Woop"));
        }
        public Gee.ArrayList<Models.Environment> get_environments () {
            return envs;
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
            return envs.get (0);
        }

        public void set_current_environment (Models.Environment env) {
            // Do something
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
