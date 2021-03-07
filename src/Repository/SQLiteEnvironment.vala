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
    public class SQLiteEnvironment : IEnvironment, Object {
        private weak Sqlite.Database db;

        public SQLiteEnvironment (Sqlite.Database d) {
            db = d;
        }

        public void delete_environment (string name) {
            var query = """DELETE FROM Environment
            WHERE name=$NAME;
            """;
            Sqlite.Statement stmt;
            int rc = db.prepare_v2 (query, query.length, out stmt);

            if (rc == Sqlite.ERROR) {
                warning ("Could not delete environment\n");
                return;
            }

            int name_pos = stmt.bind_parameter_index ("$NAME");

            stmt.bind_text (name_pos, name);

            stmt.step ();

            var environments = get_environments ();
            if (environments.size == 0) {
                get_current_environment (); // Creates default environment
            } else {
                set_current_environment (environments.get(0));
            }
        }

        public void duplicate_environment (string name) {
            int duplicateNo = 1;
            var duplicatedName = "";
            duplicatedName = "%s-%d".printf (name, duplicateNo);

            var env = get_environment_by_name (duplicatedName);

            while (env != null) {
                duplicateNo += 1;
                duplicatedName = "%s-%d".printf (name, duplicateNo);
                env = get_environment_by_name (duplicatedName);
            }

            create_environment (duplicatedName);
        }

        public Gee.ArrayList<Models.Environment> get_environments () {
            var environments = new Gee.ArrayList<Models.Environment> ();
            var query = """
            SELECT name, created_at
            FROM Environment
            ORDER BY created_at ASC;
            """;
            Sqlite.Statement stmt;
            int rc = db.prepare_v2 (query, query.length, out stmt);

            if (rc == Sqlite.ERROR) {
                warning ("Could not load environment\n");
                return environments;
            }

            int cols = stmt.column_count ();

            while (stmt.step () == Sqlite.ROW) {
                var environment = new Models.Environment.empty ();

                for (int i = 0; i < cols; i++) {
                    string col_name = stmt.column_name (i) ?? "<none>";

                    switch (col_name) {
                        case "name":
                            environment.name = stmt.column_text (i);
                            break;
                        case "created_at":
                            environment.created_at = new DateTime.from_unix_utc (stmt.column_int (i));
                            break;
                    }
                }
                environments.add (environment);
            }

            return environments;
        }

        public void add_variable_to_environment (string env_name) {
            var query = """INSERT INTO Variable
            (id, "key", value, created_at, environment_name)
            VALUES($ID, '', '', $CREATED_AT, $ENV_NAME);
            """;

            Sqlite.Statement stmt;
            int rc = db.prepare_v2 (query, query.length, out stmt);

            if (rc == Sqlite.ERROR) {
                warning ("Could not create environment\n");
                return;
            }


            var uuid = Uuid.string_random ();
            var created_at = new DateTime.now_utc ();

            int id_pos = stmt.bind_parameter_index ("$ID");
            stmt.bind_text (id_pos, uuid);
            int created_at_pos = stmt.bind_parameter_index ("$CREATED_AT");
            stmt.bind_int64 (created_at_pos, created_at.to_unix ());
            int name_pos = stmt.bind_parameter_index ("$ENV_NAME");
            stmt.bind_text (name_pos, env_name);

            if (stmt.step () != Sqlite.DONE) {
                stderr.printf ("Error: %d: %s\n", db.errcode (), db.errmsg ());
            }
        }

        public void delete_variable_value_in_environment (Models.Environment env, string variable_id) {
            var query = """DELETE FROM Variable WHERE id=$ID and environment_name=$ENV_NAME;""";
            Sqlite.Statement stmt;
            int rc = db.prepare_v2 (query, query.length, out stmt);

            if (rc == Sqlite.ERROR) {
                warning ("Could not delete variables\n");
                return;
            }

            int id_pos = stmt.bind_parameter_index ("$ID");
            stmt.bind_text (id_pos, variable_id);

            int name_pos = stmt.bind_parameter_index ("$ENV_NAME");
            stmt.bind_text (name_pos, env.name);

            if (stmt.step () != Sqlite.DONE) {
                // Do something
            }
        }

        public Gee.ArrayList<Models.Variable> get_environment_variables (string env_name) {
            var variables = new Gee.ArrayList<Models.Variable> ();
            var query = """SELECT id, "key", value, created_at
            FROM Variable
            WHERE Variable.environment_name == $ENV_NAME;""";
            Sqlite.Statement stmt;
            int rc = db.prepare_v2 (query, query.length, out stmt);

            if (rc == Sqlite.ERROR) {
                warning ("Could not load variables\n");
                return variables;
            }

            int name_pos = stmt.bind_parameter_index ("$ENV_NAME");
            stmt.bind_text (name_pos, env_name);

            int cols = stmt.column_count ();
            while (stmt.step () == Sqlite.ROW) {
                var variable = new Models.Variable.empty ();
                for (int i = 0; i < cols; i++) {
                    string col_name = stmt.column_name (i) ?? "<none>";

                    switch (col_name) {
                        case "created_at":
                            variable.created_at = new DateTime.from_unix_utc (stmt.column_int (i));
                            break;
                        case "id":
                            variable.id = stmt.column_text (i) ;
                            break;
                        case "key":
                            variable.key = stmt.column_text (i) ;
                            break;
                        case "value":
                            variable.val = stmt.column_text (i) ;
                            break;
                    }
                }
                variables.add (variable);
            }

            return variables;
        }

        public Models.Variable? get_variables_in_current_environment_by_name (string variable_name) {
            return get_variables_in_environment_by_name (Settings.get_instance ().current_environment, variable_name);
        }

        public Models.Variable? get_variables_in_environment_by_name (string env_name, string variable_name) {
            var query = """SELECT id, "key", value, created_at
            FROM Variable
            WHERE Variable.key=$NAME AND Variable.environment_name=$ENV_NAME;""";
            Sqlite.Statement stmt;
            int rc = db.prepare_v2 (query, query.length, out stmt);

            if (rc == Sqlite.ERROR) {
                warning ("Could not load variables\n");
                return null;
            }

            int name_pos = stmt.bind_parameter_index ("$ENV_NAME");
            stmt.bind_text (name_pos, env_name);

            int id_pos = stmt.bind_parameter_index ("$NAME");
            stmt.bind_text (id_pos, variable_name);

            int cols = stmt.column_count ();
            while (stmt.step () == Sqlite.ROW) {
                var variable = new Models.Variable.empty ();
                for (int i = 0; i < cols; i++) {
                    string col_name = stmt.column_name (i) ?? "<none>";

                    switch (col_name) {
                        case "created_at":
                            variable.created_at = new DateTime.from_unix_utc (stmt.column_int (i));
                            break;
                        case "id":
                            variable.id = stmt.column_text (i) ;
                            break;
                        case "key":
                            variable.key = stmt.column_text (i) ;
                            break;
                        case "value":
                            variable.val = stmt.column_text (i) ;
                            break;
                    }
                }
                return variable;
            }

            return null;
        }

        public void update_variable_name_in_environment (Models.Environment env, string id, string key) {
            var query = """UPDATE Variable
            SET "key"=$KEY
            WHERE id=$ID AND  environment_name=$ENV_NAME;
            """;

            Sqlite.Statement stmt;
            int rc = db.prepare_v2 (query, query.length, out stmt);

            if (rc == Sqlite.ERROR) {
                warning ("Could not updaet load variable key\n");
                return;
            }

            int id_pos = stmt.bind_parameter_index ("$ID");
            stmt.bind_text (id_pos, id);

            int name_pos = stmt.bind_parameter_index ("$ENV_NAME");
            stmt.bind_text (name_pos, env.name);

            int key_pos = stmt.bind_parameter_index ("$KEY");
            stmt.bind_text (key_pos, key);
            if (stmt.step () != Sqlite.DONE) {
                // Do something
            }
        }

        public void update_variable_value_in_environment (Models.Environment env, string id, string value) {
            var query = """UPDATE Variable
            SET "value"=$VALUE
            WHERE id=$ID AND  environment_name=$ENV_NAME;
            """;

            Sqlite.Statement stmt;
            int rc = db.prepare_v2 (query, query.length, out stmt);

            if (rc == Sqlite.ERROR) {
                warning ("Could not updaet load variable value\n");
                return;
            }

            int id_pos = stmt.bind_parameter_index ("$ID");
            stmt.bind_text (id_pos, id);

            int name_pos = stmt.bind_parameter_index ("$ENV_NAME");
            stmt.bind_text (name_pos, env.name);

            int value_pos = stmt.bind_parameter_index ("$VALUE");
            stmt.bind_text (value_pos, value);
            if (stmt.step () != Sqlite.DONE) {
                // Do something
            }
        }

        public Models.Environment? get_environment_by_name (string name) {
            var query = """
            SELECT name, created_at
            FROM Environment
            WHERE Environment.name = $NAME;""";
            Sqlite.Statement stmt;
            int rc = db.prepare_v2 (query, query.length, out stmt);

            if (rc == Sqlite.ERROR) {
                warning ("Could not load environment\n");
                return null;
            }

            int name_pos = stmt.bind_parameter_index ("$NAME");
            stmt.bind_text (name_pos, name);

            int cols = stmt.column_count ();
            while (stmt.step () == Sqlite.ROW) {
                var environment = new Models.Environment.empty ();
                for (int i = 0; i < cols; i++) {
                    string col_name = stmt.column_name (i) ?? "<none>";

                    switch (col_name) {
                        case "created_at":
                            environment.created_at = new DateTime.from_unix_utc (stmt.column_int (i));
                            break;
                        case "name":
                            environment.name = stmt.column_text (i) ;
                            break;
                    }
                }
                return environment;
            }

            return null;
        }

        public Models.Environment get_current_environment () {
            var settings = Settings.get_instance ();

            var env = get_environment_by_name (settings.current_environment);

            if (env == null) {
                var default_env_name = _("Default Environment");

                try {
                    create_environment (default_env_name);
                    env = get_environment_by_name (default_env_name);
                } catch (RecordExistsError error) {
                    set_current_environment (new Models.Environment (default_env_name));
                    env = get_environment_by_name (default_env_name);
                }
            }

            return env;
        }

        public void set_current_environment (Models.Environment env) {
            Settings.get_instance ().current_environment = env.name;
        }

        public void create_environment (string name) throws RecordExistsError {
            Sqlite.Statement stmt;
            var insert_query = """INSERT INTO Environment
            (name, created_at)
            VALUES($NAME, $CREATED_AT);
            """;

            int ec = db.prepare_v2 (insert_query, insert_query.length, out stmt);
            if (ec != Sqlite.OK) {
                stderr.printf ("Error: %d: %s\n", db.errcode (), db.errmsg ());
            }

            int name_pos = stmt.bind_parameter_index ("$NAME");
            int created_at_pos = stmt.bind_parameter_index ("$CREATED_AT");

            var created_at = new DateTime.now_utc ();

            stmt.bind_text (name_pos, name);
            stmt.bind_int64 (created_at_pos, created_at.to_unix ());

            if (stmt.step () != Sqlite.DONE) {
                throw new RecordExistsError.CODE_1A ("%s", db.errmsg ());
            }
        }
    }
}
