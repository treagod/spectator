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


namespace Spectator.Repository {
    public class SQLiteCollection : ICollection, Object {
        private weak Sqlite.Database db;

        public SQLiteCollection (Sqlite.Database db) {
            this.db = db;
        }
        public Gee.ArrayList<Models.Collection> get_collections () {
            var collections = new Gee.ArrayList<Models.Collection> ();
            var query = "SELECT * FROM Collection;";
            Sqlite.Statement stmt;
            int rc = db.prepare_v2 (query, query.length, out stmt);

            if (rc == Sqlite.ERROR) {
                warning ("Could not load collections\n");
                return collections;
            }

            int cols = stmt.column_count ();
            while (stmt.step () == Sqlite.ROW) {
                var collection = new Models.Collection ("ad"); // Make empty constructor

                for (int i = 0; i < cols; i++) {
                    string col_name = stmt.column_name (i) ?? "<none>";

                    switch (col_name) {
                        case "id":
                            collection.id = stmt.column_int (i);
                            break;
                        case "name":
                            collection.name = stmt.column_text (i) ;
                            break;
                    }
                }
                collections.add (collection);
            }

            return collections;
        }

        public bool delete_collection (uint id) {
            Sqlite.Statement stmt;
            string insert_query = "DELETE FROM Collection WHERE id = $COLLECTION_ID;";

            int ec = db.prepare_v2 (insert_query, insert_query.length, out stmt);
            if (ec != Sqlite.OK) {
                stderr.printf ("Error: %d: %s\n", db.errcode (), db.errmsg ());
            }

            int id_pos = stmt.bind_parameter_index ("$COLLECTION_ID");
            stmt.bind_int (id_pos, (int) id);

            if (stmt.step () != Sqlite.DONE) {
                stderr.printf ("Error: %d: %s\n", db.errcode (), db.errmsg ());
            }

            return true;
        }

        public bool add_request_to_collection (uint collection_id, uint request_id) {
            Sqlite.Statement stmt;
            string insert_query = """
            UPDATE Request
            SET collection_id = $COLLECTION_ID
            WHERE id = $REQUEST_ID;
            """;

            int ec = db.prepare_v2 (insert_query, insert_query.length, out stmt);
            if (ec != Sqlite.OK) {
                stderr.printf ("Error: %d: %s\n", db.errcode (), db.errmsg ());
            }

            int collection_id_pos = stmt.bind_parameter_index ("$COLLECTION_ID");
            stmt.bind_int (collection_id_pos, (int) collection_id);

            int request_id_pos = stmt.bind_parameter_index ("$REQUEST_ID");
            stmt.bind_int (request_id_pos, (int) request_id);

            if (stmt.step () != Sqlite.DONE) {
                stderr.printf ("Error: %d: %s\n", db.errcode (), db.errmsg ());
            }
            return true;
        }

        public bool add_collection (Models.Collection collection) {
            Sqlite.Statement stmt;
            string insert_query = "INSERT INTO Collection (name) VALUES ($NAME);";

            int ec = db.prepare_v2 (insert_query, insert_query.length, out stmt);
            if (ec != Sqlite.OK) {
                stderr.printf ("Error: %d: %s\n", db.errcode (), db.errmsg ());
            }

            int name_pos = stmt.bind_parameter_index ("$NAME");

            stmt.bind_text (name_pos, collection.name);

            if (stmt.step () != Sqlite.DONE) {
                stderr.printf ("Error: %d: %s\n", db.errcode (), db.errmsg ());
            }

            collection.id = (uint) this.db.last_insert_rowid ();

            return true;
        }

        public void rename (uint id, string name) {
            Sqlite.Statement stmt;
            string insert_query = """
            UPDATE Collection
            SET name = $NEW_NAME
            WHERE id = $COLLECTION_ID;
            """;

            int ec = db.prepare_v2 (insert_query, insert_query.length, out stmt);
            if (ec != Sqlite.OK) {
                stderr.printf ("Error: %d: %s\n", db.errcode (), db.errmsg ());
            }

            int name_pos = stmt.bind_parameter_index ("$NEW_NAME");
            stmt.bind_text (name_pos, name);

            int id_pos = stmt.bind_parameter_index ("$COLLECTION_ID");
            stmt.bind_int (id_pos, (int) id);

            if (stmt.step () != Sqlite.DONE) {
                stderr.printf ("Error: %d: %s\n", db.errcode (), db.errmsg ());
            }
        }

        public Models.Collection? get_collection_by_id (uint id) {
            var collection = new Models.Collection ("dummy");
            var query = "SELECT * FROM Collection WHERE id = $COLLECTION_ID;";
            Sqlite.Statement stmt;
            int rc = db.prepare_v2 (query, query.length, out stmt);

            if (rc == Sqlite.ERROR) {
                warning ("Could not load collection\n");
                return null;
            }

            int id_pos = stmt.bind_parameter_index ("$COLLECTION_ID");
            stmt.bind_int (id_pos, (int) id);

            int cols = stmt.column_count ();
            while (stmt.step () == Sqlite.ROW) {
                for (int i = 0; i < cols; i++) {
                    string col_name = stmt.column_name (i) ?? "<none>";

                    switch (col_name) {
                        case "id":
                            collection.id = stmt.column_int (i);
                            break;
                        case "name":
                            collection.name = stmt.column_text (i) ;
                            break;
                    }
                }
            }

            return collection;
        }

        public void append_after_request_to_collection (uint collection_id, uint target_id, uint moved_id) {
        }

        public Gee.ArrayList<Models.Request> get_requests (uint id) {
            var requests = new Gee.ArrayList<Models.Request> ();

            var query = """
            SELECT *
            FROM Request
            INNER JOIN CustomOrder ON Request.id = CustomOrder.id AND CustomOrder.type = 0
            WHERE collection_id = $COLLECTION_ID
            ORDER BY position;
            """;
            Sqlite.Statement stmt;
            int rc = db.prepare_v2 (query, query.length, out stmt);

            if (rc == Sqlite.ERROR) {
                warning ("Could not load requests\n");
                return requests;
            }

            int id_pos = stmt.bind_parameter_index ("$COLLECTION_ID");
            stmt.bind_int (id_pos, (int) id);

            int cols = stmt.column_count ();
            while (stmt.step () == Sqlite.ROW) {
                var request = new Models.Request (); // Make empty constructor

                for (int i = 0; i < cols; i++) {
                    string col_name = stmt.column_name (i) ?? "<none>";

                    switch (col_name) {
                        case "id":
                            request.id = stmt.column_int (i);
                            break;
                        case "name":
                            request.name = stmt.column_text (i) ;
                            break;
                        case "url":
                            request.uri = stmt.column_text (i) ?? "";
                            break;
                        case "method":
                            request.method = Models.Method.convert (stmt.column_int (i));
                            break;
                        case "last_sent":
                            request.last_sent = new DateTime.from_unix_local (stmt.column_int64 (i));
                            break;
                        case "collection_id":
                            break; // NecessaryP
                    }
                }
                requests.add (request);
            }

            return requests;
        }
    }
}
