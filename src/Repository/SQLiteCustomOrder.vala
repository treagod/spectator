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
    public class SQLiteCustomOrder : Repository.ICustomOrder, Object {
        private weak Sqlite.Database db;

        public SQLiteCustomOrder (Sqlite.Database db) {
            this.db = db;
        }

        public Gee.ArrayList<Models.Order> get_order () {
            var order = new Gee.ArrayList<Models.Order> ();
            var query = """
            SELECT CustomOrder.id, CustomOrder.type, CustomOrder.position FROM CustomOrder
            INNER JOIN
                (
                    SELECT id, 0 AS type
                    FROM Request
                    WHERE Request.collection_id IS NULL
                    UNION
                    SELECT id, 1 as type
                    FROM Collection
                ) AS CollectionAndRequests
            ON CustomOrder.id = CollectionAndRequests.id AND CustomOrder.type = CollectionAndRequests.type
            ORDER BY CustomOrder.position ASC;
            """;
            Sqlite.Statement stmt;
            int rc = db.prepare_v2 (query, query.length, out stmt);

            if (rc == Sqlite.ERROR) {
                warning ("Could not load order\n");
                return order;
            }

            int cols = stmt.column_count ();
            while (stmt.step () == Sqlite.ROW) {
                var entry = new Models.Order (1, Models.Order.Type.REQUEST); // Make empty constructor

                for (int i = 0; i < cols; i++) {
                    string col_name = stmt.column_name (i) ?? "<none>";

                    switch (col_name) {
                        case "id":
                            entry.id = stmt.column_int (i);
                            break;
                        case "type":
                            entry.type = (Models.Order.Type) stmt.column_int (i) ;
                            break;
                    }
                }

                order.add (entry);
            }

            return order;
        }

        public void move_request_after_request (uint target_id, uint moved_id) {
            this.db.exec ("BEGIN TRANSACTION;");
            var reposition_other_query = Queries.CustomOrder.MOVE_REQUEST_AFTER_REQUEST.replace ("$MOVED_ID", "%u".printf (moved_id)).replace ("$TARGET_ID", "%u".printf (target_id));


            var reposition_moved_request_query = """
            UPDATE CustomOrder
            SET position = (SELECT position FROM CustomOrder WHERE id = $TARGET_ID) + 1
            WHERE id = $MOVED_ID AND type = 0;
            """.replace ("$MOVED_ID", "%u".printf (moved_id)).replace ("$TARGET_ID", "%u".printf (target_id));

            this.db.exec (reposition_other_query);
            this.db.exec (reposition_moved_request_query);
            this.db.exec ("COMMIT;");
        }

        public void move_request_to_end (uint moved_id) {
            this.db.exec ("BEGIN TRANSACTION;");
            Sqlite.Statement stmt;
            string insert_query = """
            UPDATE CustomOrder
            SET position = position - 1
            WHERE position > (SELECT position FROM CustomOrder WHERE id = $MOVED_ID);
            """;

            int ec = this.db.prepare_v2 (insert_query, insert_query.length, out stmt);
            if (ec != Sqlite.OK) {
                stderr.printf ("Error: %d: %s\n", db.errcode (), db.errmsg ());
            }

            int id_pos = stmt.bind_parameter_index ("$MOVED_ID");

            stmt.bind_int (id_pos, (int) moved_id);

            if (stmt.step () != Sqlite.DONE) {
                stderr.printf ("Error: %d: %s\n", db.errcode (), db.errmsg ());
            }

            stmt.reset ();

            insert_query = """
            UPDATE CustomOrder
            SET position = ((SELECT COUNT(*) FROM CustomOrder) - 1)
            WHERE id = $MOVED_ID AND type = 0;
            """;

            ec = this.db.prepare_v2 (insert_query, insert_query.length, out stmt);
            if (ec != Sqlite.OK) {
                stderr.printf ("Error: %d: %s\n", db.errcode (), db.errmsg ());
            }

            id_pos = stmt.bind_parameter_index ("$MOVED_ID");

            stmt.bind_int (id_pos, (int) moved_id);

            if (stmt.step () != Sqlite.DONE) {
                stderr.printf ("Error: %d: %s\n", db.errcode (), db.errmsg ());
            }

            this.db.exec ("""
            UPDATE Request
            SET collection_id = NULL
            WHERE id = $MOVED_ID;
            """.replace ("$MOVED_ID", "%u".printf (moved_id)));

            this.db.exec ("COMMIT;");
        }


        public bool add_request_to_collection_begin (uint collection_id, uint request_id) {
            this.db.exec ("BEGIN TRANSACTION;");

            var change_requests_collection_id_query = """
            UPDATE Request
            SET collection_id = $TARGET_ID
            WHERE id = $MOVED_ID;
            """.replace ("$MOVED_ID", "%u".printf (request_id)).replace ("$TARGET_ID", "%u".printf (collection_id));

            var reposition_other_query = """
            UPDATE CustomOrder
            SET position = CASE
            WHEN (SELECT position FROM CustomOrder WHERE id = $MOVED_ID AND type = 0) > (SELECT position FROM CustomOrder WHERE id = $TARGET_ID AND type = 1) THEN position + 1
            ELSE position - 1
            END
            WHERE
            position
            BETWEEN CASE
            WHEN (SELECT position FROM CustomOrder WHERE id = $MOVED_ID AND type = 0) > (SELECT position FROM CustomOrder WHERE id = $TARGET_ID and type = 1)
            THEN (SELECT position FROM CustomOrder WHERE id = $TARGET_ID AND type = 1) + 1
            ELSE (SELECT position FROM CustomOrder WHERE id = $MOVED_ID AND type = 0) + 1
            END
            AND CASE
            WHEN (SELECT position FROM CustomOrder WHERE id = $MOVED_ID AND type = 0) > (SELECT position FROM CustomOrder WHERE id = $TARGET_ID AND type = 1)
            THEN (SELECT position FROM CustomOrder WHERE id = $MOVED_ID AND type = 0) - 1
            ELSE (SELECT position FROM CustomOrder WHERE id = $TARGET_ID AND type = 1)
            END;
            """.replace ("$MOVED_ID", "%u".printf (request_id)).replace ("$TARGET_ID", "%u".printf (collection_id));


            var reposition_moved_request_query = """
            UPDATE CustomOrder
            SET position = (SELECT position FROM CustomOrder WHERE id = $TARGET_ID AND type = 1) + 1
            WHERE id = $MOVED_ID;
            """.replace ("$MOVED_ID", "%u".printf (request_id)).replace ("$TARGET_ID", "%u".printf (collection_id));

            this.db.exec (change_requests_collection_id_query);
            this.db.exec (reposition_other_query);
            this.db.exec (reposition_moved_request_query);
            this.db.exec ("COMMIT;");

            return true;
        }

        public void move_request_to_begin (uint moved_id) {
            this.db.exec ("BEGIN TRANSACTION;");
            Sqlite.Statement stmt;
            string insert_query = """
            UPDATE CustomOrder
            SET position = position + 1
            WHERE position < (SELECT position FROM CustomOrder WHERE id = $MOVED_ID AND type = 0);
            """;

            int ec = this.db.prepare_v2 (insert_query, insert_query.length, out stmt);
            if (ec != Sqlite.OK) {
                stderr.printf ("Error: %d: %s\n", db.errcode (), db.errmsg ());
            }

            int id_pos = stmt.bind_parameter_index ("$MOVED_ID");

            stmt.bind_int (id_pos, (int) moved_id);

            if (stmt.step () != Sqlite.DONE) {
                stderr.printf ("Error: %d: %s\n", db.errcode (), db.errmsg ());
            }

            stmt.reset ();

            insert_query = """
            UPDATE CustomOrder
            SET position = 0
            WHERE id = $MOVED_ID AND type = 0;
            """;

            ec = this.db.prepare_v2 (insert_query, insert_query.length, out stmt);
            if (ec != Sqlite.OK) {
                stderr.printf ("Error: %d: %s\n", db.errcode (), db.errmsg ());
            }

            id_pos = stmt.bind_parameter_index ("$MOVED_ID");

            stmt.bind_int (id_pos, (int) moved_id);

            if (stmt.step () != Sqlite.DONE) {
                stderr.printf ("Error: %d: %s\n", db.errcode (), db.errmsg ());
            }

            this.db.exec ("""
            UPDATE Request
            SET collection_id = NULL
            WHERE id = $MOVED_ID;
            """.replace ("$MOVED_ID", "%u".printf (moved_id)));

            this.db.exec ("COMMIT;");
        }

        public void append_after_request_to_collection_requests (uint collection_id, uint target_id, uint moved_id) {
            this.db.exec ("BEGIN TRANSACTION;");

            var change_requests_collection_id_query = """
            UPDATE Request
            SET collection_id = $TARGET_ID
            WHERE id = $MOVED_ID;
            """.replace ("$MOVED_ID", "%u".printf (moved_id)).replace ("$TARGET_ID", "%u".printf (collection_id));

            var reposition_other_query = """
            UPDATE CustomOrder
            SET position = CASE
            WHEN (SELECT position FROM CustomOrder WHERE id = $MOVED_ID AND type = 0) > (SELECT position FROM CustomOrder WHERE id = $TARGET_ID AND type = 0) THEN position + 1
            ELSE position - 1
            END
            WHERE
            position
            BETWEEN CASE
            WHEN (SELECT position FROM CustomOrder WHERE id = $MOVED_ID AND type = 0) > (SELECT position FROM CustomOrder WHERE id = $TARGET_ID and type = 0)
            THEN (SELECT position FROM CustomOrder WHERE id = $TARGET_ID AND type = 0) + 1
            ELSE (SELECT position FROM CustomOrder WHERE id = $MOVED_ID AND type = 0) + 1
            END
            AND CASE
            WHEN (SELECT position FROM CustomOrder WHERE id = $MOVED_ID AND type = 0) > (SELECT position FROM CustomOrder WHERE id = $TARGET_ID AND type = 0)
            THEN (SELECT position FROM CustomOrder WHERE id = $MOVED_ID AND type = 0) - 1
            ELSE (SELECT position FROM CustomOrder WHERE id = $TARGET_ID AND type = 0)
            END;
            """.replace ("$MOVED_ID", "%u".printf (moved_id)).replace ("$TARGET_ID", "%u".printf (target_id));


            var reposition_moved_request_query = """
            UPDATE CustomOrder
            SET position = (SELECT position FROM CustomOrder WHERE id = $TARGET_ID AND type = 0) + 1
            WHERE id = $MOVED_ID;
            """.replace ("$MOVED_ID", "%u".printf (moved_id)).replace ("$TARGET_ID", "%u".printf (target_id));

            this.db.exec (change_requests_collection_id_query);
            this.db.exec (reposition_other_query);
            this.db.exec (reposition_moved_request_query);
            this.db.exec ("COMMIT;");
        }
    }
}
