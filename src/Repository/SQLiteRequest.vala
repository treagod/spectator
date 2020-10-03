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

        public SQLiteRequest (Sqlite.Database db) {
            this.db = db;
        }


        public void update_request (uint id, UpdateCallback cb) {
            var request = this.get_request_by_id (id);

            if (request == null) {
                warning ("Could not update non existing request with id %u\n", id);
                return;
            }

            SQLiteRequestUpdater updater = new SQLiteRequestUpdater (request, this.db);
            cb (updater);
            updater.save ();
        }

        public Gee.ArrayList<Models.Request> get_requests () {
            var requests = new Gee.ArrayList<Models.Request> ();
            var query = """
            SELECT Request.id, name, method, url, last_sent, type as body_type, content as body_content
            FROM Request
            INNER JOIN RequestBody ON Request.id = RequestBody.id;
            """;
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
                            unowned var last_sent_value = stmt.column_value (i);
                            
                            if (last_sent_value.to_type () != Sqlite.NULL) {
                                request.last_sent = new DateTime.from_unix_local (stmt.column_int64 (i));
                            }
                            
                            break;
                        case "body_type":
                            request.request_body.type = RequestBody.ContentType.convert (stmt.column_int (i));
                            break;
                        case "body_content":
                            request.request_body.content = stmt.column_text (i);
                            break;
                    }
                }
                requests.add (request);
            }

            return requests;
        }

        public bool add_request (Models.Request request) {
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

            return false;
        }

        public Models.Request? get_request_by_id (uint id) {
            var request = new Models.Request ();
            var query = """
            SELECT Request.id, name, method, url, last_sent, type as body_type, content as body_content
            FROM Request
            INNER JOIN RequestBody ON Request.id = RequestBody.id
            WHERE Request.id = $REQUEST_ID;""";
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
                            unowned var last_sent_value = stmt.column_value (i);
                                
                            if (last_sent_value.to_type () != Sqlite.NULL) {
                                request.last_sent = new DateTime.from_unix_local (stmt.column_int64 (i));
                            }
                            
                            break;
                        case "body_type":
                            request.request_body.type = RequestBody.ContentType.convert (stmt.column_int (i));
                            break;
                        case "body_content":
                            request.request_body.content = stmt.column_text (i);
                            break;
                    }
                }
            }

            return request;
        }
    }
}
