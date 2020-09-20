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
    public class SQLiteRequest : IRequest, Object {
        private weak Sqlite.Database db;

        public signal void request_added (Models.Request request);
        public signal void request_deleted (uint id);

        public SQLiteRequest (Sqlite.Database db) {
            this.db = db;
        }

        public Gee.ArrayList<Models.Request> get_requests () {
            var requests = new Gee.ArrayList<Models.Request> ();
            var query = "SELECT * FROM Request;";
            Sqlite.Statement stmt;
            int rc = db.prepare_v2 (query, query.length, out stmt);

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

        public bool add_request (Models.Request request) {
            if (this.db != null) {
                Sqlite.Statement stmt;
                string insert_query = """
                INSERT INTO Request (name, method) VALUES ($NAME, $METHOD);
                """;

                int ec = db.prepare_v2 (insert_query, insert_query.length, out stmt);
                if (ec != Sqlite.OK) {
                stderr.printf ("Error: %d: %s\n", db.errcode (), db.errmsg ());
                }

                int name_pos = stmt.bind_parameter_index ("$NAME");
                int method_pos = stmt.bind_parameter_index ("$METHOD");

                stmt.bind_text (name_pos, request.name);
                stmt.bind_int (method_pos, request.method.to_i ());

                if (stmt.step () != Sqlite.DONE) {
                    stderr.printf ("Error: %d: %s\n", db.errcode (), db.errmsg ());
                }

                request.id = (uint) this.db.last_insert_rowid ();
            }

            this.request_added (request);

            return true;
        }

        public bool delete_request (uint id) {
            Sqlite.Statement stmt;
            string insert_query = """
            DELETE FROM Request WHERE id = $REQUEST_ID;
            """;

            int ec = db.prepare_v2 (insert_query, insert_query.length, out stmt);
            if (ec != Sqlite.OK) {
            stderr.printf ("Error: %d: %s\n", db.errcode (), db.errmsg ());
            }

            int id_pos = stmt.bind_parameter_index ("$REQUEST_ID");

            stmt.bind_int (id_pos, (int) id);

            if (stmt.step () != Sqlite.DONE) {
                stderr.printf ("Error: %d: %s\n", db.errcode (), db.errmsg ());
            }

            this.request_deleted (id);

            return false;
        }

        public bool set_collection_id_for_request (uint request_id, uint collection_id) {
            var request = this.get_request_by_id (request_id);

            if (request != null) {
                // request.collection_id = collection_id;
                return true;
            } else {
                return false;
            }
        }

        public Models.Request? get_request_by_id (uint id) {
            var request = new Models.Request ();
            var query = "SELECT * FROM Request WHERE id = $REQUEST_ID;";
            Sqlite.Statement stmt;
            int rc = db.prepare_v2 (query, query.length, out stmt);

            int id_pos = stmt.bind_parameter_index ("$REQUEST_ID");
            stmt.bind_int (id_pos, (int) id);

            int cols = stmt.column_count ();
            while (stmt.step () == Sqlite.ROW) {
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
            }

            return request;
        }
    }
}
