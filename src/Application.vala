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

        private void ensure_directory () {
            if (FileUtils.test (this.app_data_dir, FileTest.EXISTS)) {
                if (!FileUtils.test(this.app_data_dir, GLib.FileTest.IS_DIR)) {
                    error ("%s must be a directory\n", this.app_data_dir);
                }
            } else {
                try {
                    File file = File.new_for_commandline_arg (this.app_data_dir);
                    file.make_directory_with_parents ();
                } catch (Error e) {
                    error ("Could not create %s\n", this.app_data_dir);
                }
            }
        }

        private void load_database () {
            string errmsg;
            this.ensure_directory ();

            int ec = Sqlite.Database.open (
                Path.build_filename (
                    this.app_data_dir,
                    "%s.db".printf (Constants.PROJECT_NAME)
                ),
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

        protected override void activate () {
            this.load_database ();
            if (!running) {
                var rs = new Repository.SQLiteRequest (db);
                var cs = new Repository.SQLiteCollection (db);
                var os = new Repository.SQLiteCustomOrder (db);
                this.load_legacy (cs, rs);

                var window = new Spectator.Window(this, rs, cs, os);
                this.add_window (window);

                window.show_all ();
                running = true;
            }
        }
    }
}
