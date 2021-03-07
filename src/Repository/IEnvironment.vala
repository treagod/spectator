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
    public errordomain RecordExistsError {
        CODE_1A
    }

    public interface IEnvironment : Object {
        public abstract Gee.ArrayList<Models.Environment> get_environments ();
        public abstract Models.Environment? get_environment_by_name (string name);
        public abstract Models.Environment get_current_environment ();
        public abstract void create_environment (string name) throws RecordExistsError;
        public abstract void delete_environment (string name);
        public abstract void duplicate_environment (string name);
        public abstract void update_environment (string old_name, string name);
        public abstract void set_current_environment (Models.Environment env);
        public abstract void add_variable_to_environment (string env_name);
        public abstract void delete_variable_value_in_environment (Models.Environment env, string variable_id);
        public abstract Gee.ArrayList<Models.Variable> get_environment_variables(string env_name);
        public abstract void update_variable_name_in_environment (Models.Environment env, string id, string key);
        public abstract void update_variable_value_in_environment (Models.Environment env, string id, string value1);
        public abstract Models.Variable? get_variables_in_environment_by_name (string env_name, string variable_name);
        public abstract Models.Variable? get_variables_in_current_environment_by_name (string variable_name);
    }
}
