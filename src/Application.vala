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

    public class Order {
        public enum Type {
            REQUEST,
            COLLECTION
        }

        public Type type;
        public uint id;

        public Order (uint id, Type type) {
            this.type = type;
            this.id = id;
        }
    }

    public class Application : Gtk.Application {
        // Avoid multiple instances
        public bool running = false;
        private string app_data_dir = Path.build_filename (
            Environment.get_home_dir (),
            ".local",
            "share",
            Constants.PROJECT_NAME,
            "%s.db".printf (Constants.PROJECT_NAME)
        );
        private Sqlite.Database db;
        construct {
            flags |= ApplicationFlags.HANDLES_OPEN;
            application_id = "com.github.treagod.spectator";
        }

        private void load_database () {
            string errmsg;

            int ec = Sqlite.Database.open (this.app_data_dir, out db);
            if (ec != Sqlite.OK) {
                stderr.printf ("Can't open database: %d: %s\n", db.errcode (), db.errmsg ());
                //  return -1;
            }

            string query = Spectator.SQL_INIT_CMD;

            ec = db.exec (query, null, out errmsg);
            if (ec != Sqlite.OK) {
                stderr.printf ("Error: %s\n", errmsg);
                //  return -1;
            }
        }

        protected override void activate () {
            this.load_database ();
            if (!running) {
                var rs = new Repository.SQLiteRequest (db);
                var cs = new Repository.SQLiteCollection (db);
                var os = new Repository.SQLiteCustomOrder (db);

                var window = new Spectator.Window(this, rs, cs, os);
                this.add_window (window);

                window.show_all ();
                running = true;
            }
        }
    }
}
