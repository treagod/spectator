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

namespace Spectator {
    public class Application : Gtk.Application {
        // Avoid multiple instances
        public bool running = false;
        private string app_data_dir = Path.build_filename (
            Environment.get_home_dir (),
            ".local",
            "share",
            Constants.PROJECT_NAME
        );
        private Sqlite.Database db;
        construct {
            flags |= ApplicationFlags.HANDLES_OPEN;
            application_id = "com.github.treagod.spectator";
        }

        private void ensure_directory (string db_path) {
            if (FileUtils.test (db_path, FileTest.EXISTS)) {
                if (!FileUtils.test(db_path, GLib.FileTest.IS_DIR)) {
                    error ("%s must be a directory\n", db_path);
                }
            } else {
                try {
                    File file = File.new_for_commandline_arg (db_path);
                    file.make_directory_with_parents ();
                } catch (Error e) {
                    error ("Could not create %s\n", db_path);
                }
            }
        }

        private void load_database () {
            string errmsg;
            string? db_path = Environment.get_variable ("XDG_DATA_HOME");

            if (db_path == null) {
                this.ensure_directory (this.app_data_dir);
                db_path = Path.build_filename (
                    this.app_data_dir,
                    "%s.db".printf (Constants.PROJECT_NAME)
                );
            } else if(db_path.length > 0) {
                this.ensure_directory (db_path);
                db_path = Path.build_filename (
                    db_path,
                    "%s.db".printf (Constants.PROJECT_NAME)
                );
            }

            int ec = Sqlite.Database.open (
                db_path,
                out db
            );
            if (ec != Sqlite.OK) {
                stderr.printf ("Can't open database: %d: %s\n", db.errcode (), db.errmsg ());
                Process.exit(1);
            }

            string query = Spectator.Queries.SQL_INIT_CMD;

            ec = db.exec (query, null, out errmsg);
            if (ec != Sqlite.OK) {
                stderr.printf ("Error: %s\n", errmsg);
                Process.exit(1);
            }

            var db_version = get_db_version ();

            if (db_version >= 60) {
                ec = db.exec (Queries.Migrate060.CREATE_ENVIRONMENT_TABLE, null, out errmsg);
                if (ec != Sqlite.OK) {
                    stderr.printf ("Error: %s\n", errmsg);
                    Process.exit(1);
                }
                ec = db.exec (Queries.Migrate060.CREATE_VARIABLE_TABLE, null, out errmsg);
                if (ec != Sqlite.OK) {
                    stderr.printf ("Error: %s\n", errmsg);
                    Process.exit(1);
                }
            } else if (db_version < 60) {
                ec = db.exec (Queries.Migrate060.DROP_ENVIRONMENT_TABLE, null, out errmsg);
                if (ec != Sqlite.OK) {
                    stderr.printf ("Error: %s\n", errmsg);
                    Process.exit(1);
                }
                ec = db.exec (Queries.Migrate060.DROP_VARIABLE_TABLE, null, out errmsg);
                if (ec != Sqlite.OK) {
                    stderr.printf ("Error: %s\n", errmsg);
                    Process.exit(1);
                }
            }
        }

        private void load_legacy (Repository.ICollection collections, Repository.IRequest requests) {
            var legacy_store_path = Path.build_filename (
                this.app_data_dir,
                "settings.json"
            );

            // Skip if no settings.json exists
            if (!FileUtils.test(legacy_store_path, GLib.FileTest.IS_REGULAR)) return;

            var ser = new Services.JsonDeserializer ();
            ser.collection_loaded.connect ((collection) => {
                collections.add_collection (collection);
            });

            ser.request_added_to_collection.connect ((collection, request) => {
                requests.add_request (request);
                collections.add_request_to_collection (collection.id, request.id);
            });
            ser.load_data_from_file (legacy_store_path);

            try {
                var file = File.new_for_path (legacy_store_path);
                file.delete ();
            } catch (Error err) {
                print ("Could not delete file %s\n", legacy_store_path);
            }
        }

        private int get_db_version () {
            var version_parts = Constants.VERSION.split(".");
            var sum = 0;
            // Coefficient, major version 'x * 100', minor version 'x * 10', bugfix version 'x * 1'
            var cof = 100;

            for (uint i = 0; i < version_parts.length; i++) {
                sum += int.parse (version_parts[i]) * cof;
                cof /= 10;
            }

            return sum;
        }

        protected override void activate () {
            this.load_database ();
            
            if (!running) {
                var rs = new Repository.SQLiteRequest (db);
                var cs = new Repository.SQLiteCollection (db);
                var os = new Repository.SQLiteCustomOrder (db);
                //var es = new Repository.InMemoryEnvironment ();
                var ses = new Repository.SQLiteEnvironment (db);
                
                
                this.load_legacy (cs, rs);
                var window_builder = new Services.WindowBuilder (rs, cs, os, ses);

                var window = window_builder.build_window (this);
                this.add_window (window);

                window.show_content ();
                running = true;
            }
        }
    }
}