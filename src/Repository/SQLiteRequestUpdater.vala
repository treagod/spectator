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
    public class SQLiteRequestUpdater : IRequestUpdater, Object {
        private Models.Request request;
        private weak Sqlite.Database db;
        private bool update_request;
        private bool update_request_body;

        public SQLiteRequestUpdater (Models.Request request, Sqlite.Database db) {
            this.request = request;
            this.db = db;
            this.update_request = false;
            this.update_request_body = false;
        }

        public void update_name (string name) {
            request.name = name;
            this.update_request = true;
        }

        public void update_script (string script) {
            request.script_code = script;
            this.update_request = true;
        }

        public void update_method (Models.Method method) {
            request.method = method;
            this.update_request = true;
        }

        public void update_url (string url) {
            request.uri = url;
            this.update_request = true;
        }

        public void update_headers (Gee.ArrayList<Pair> headers) {
            request.headers = headers;
            this.update_request = true;
        }

        public void update_body_type (RequestBody.ContentType type) {
            if (request.request_body.type != type) {
                request.request_body.type = type;
                this.update_request_body = true;
            }
        }

        public void update_body_content (string content) {
            if (request.request_body.content != content) {
                request.request_body.content = content;
                this.update_request_body = true;
            }
        }

        public void update_last_sent (DateTime last_sent) {
            request.last_sent = last_sent;
            this.update_request = true;
        }

        private void update_request_row () {
            Sqlite.Statement stmt;
            string update_query = """
            UPDATE Request
            SET name = $NAME,
                method = $METHOD,
                url = $URL,
                last_sent = $LAST_SENT,
                script = $SCRIPT,
                headers = $HEADERS
            WHERE id = $REQUEST_ID;
            """;

            int ec = db.prepare_v2 (update_query, update_query.length, out stmt);
            if (ec != Sqlite.OK) {
            stderr.printf ("Error: %d: %s\n", db.errcode (), db.errmsg ());
            }

            int name_pos = stmt.bind_parameter_index ("$NAME");
            int method_pos = stmt.bind_parameter_index ("$METHOD");
            int url_pos = stmt.bind_parameter_index ("$URL");
            int last_sent_pos = stmt.bind_parameter_index ("$LAST_SENT");
            int id_pos = stmt.bind_parameter_index ("$REQUEST_ID");
            int script_pos = stmt.bind_parameter_index ("$SCRIPT");
            int headers_pos = stmt.bind_parameter_index ("$HEADERS");

            stmt.bind_text (name_pos, request.name);
            stmt.bind_int (method_pos, request.method.to_i ());
            stmt.bind_text (url_pos, request.uri);
            stmt.bind_text (script_pos, request.script_code);
            stmt.bind_int (id_pos, (int) request.id);
            stmt.bind_text (headers_pos, serialize_key_value_content (request.headers));

            if (request.last_sent == null) {
                stmt.bind_null (last_sent_pos);
            } else {
                stmt.bind_int64 (last_sent_pos, request.last_sent.to_unix ());
            }

            if (stmt.step () != Sqlite.DONE) {
                stderr.printf ("Error: %d: %s\n", db.errcode (), db.errmsg ());
            }
        }

        private void update_request_body_row () {
            Sqlite.Statement stmt;
            string update_query = """
            UPDATE RequestBody
            SET type = $TYPE,
                content = $CONTENT
            WHERE id = $REQUEST_ID;
            """;

            int ec = db.prepare_v2 (update_query, update_query.length, out stmt);
            if (ec != Sqlite.OK) {
                stderr.printf ("Error: %d: %s\n", db.errcode (), db.errmsg ());
            }

            int type_pos = stmt.bind_parameter_index ("$TYPE");
            int content_pos = stmt.bind_parameter_index ("$CONTENT");
            int id_pos = stmt.bind_parameter_index ("$REQUEST_ID");

            stmt.bind_text (content_pos, request.request_body.content);
            stmt.bind_int (type_pos, request.request_body.type.to_i ());
            stmt.bind_int (id_pos, (int) request.id);

            if (stmt.step () != Sqlite.DONE) {
                stderr.printf ("Error: %d: %s\n", db.errcode (), db.errmsg ());
            }
        }

        private string serialize_key_value_content (Gee.ArrayList<Pair> pairs) {
            var form_data_builder = new StringBuilder ();
            foreach (var entry in pairs) {
                form_data_builder.append ("%s>>|<<%s\n".printf (entry.key, entry.val));
            }
            return form_data_builder.str;
        }

        public void save () {
            if (this.update_request) {
                this.update_request_row ();
            }

            if (this.update_request_body) {
                this.update_request_body_row ();
            }
        }
    }
}
