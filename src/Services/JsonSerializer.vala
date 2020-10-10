/*
* Copyright (c) 2019 Marvin Ahlgrimm (https://github.com/treagod)
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

/*
DEPRECATED!!!
DEPRECATED!!!
*/

namespace Spectator.Services {
    public class JsonSerializer {
        private string data;
        private Json.Builder builder;
        public JsonSerializer () {
            data = "";
            builder = new Json.Builder ();
        }

        private void serialize_header (Pair header) {
            if (header.key == "") {
                return;
            }
            builder.begin_object ();
            builder.set_member_name ("key");
            builder.add_string_value (header.key);
            builder.set_member_name ("value");
            builder.add_string_value (header.val);
            builder.end_object ();
        }

        private void serialize_headers (Models.Request request) {
            builder.set_member_name ("headers");
            builder.begin_array ();
            foreach (var header in request.headers) {
                serialize_header (header);
            }
            builder.end_array ();
        }

        private void serialize_body (Models.Request request) {
            builder.set_member_name ("body");
            builder.begin_object ();
            builder.set_member_name ("active_type");
            builder.add_int_value (request.request_body.type.to_i ());
            builder.set_member_name ("form_data");
            builder.begin_array ();
            foreach (var pair in request.request_body.get_as_form_data ()) {
                builder.begin_object ();
                builder.set_member_name ("key");
                builder.add_string_value (pair.key);
                builder.set_member_name ("value");
                builder.add_string_value (pair.val);
                builder.end_object ();
            }
            builder.end_array (); // Form data
            builder.set_member_name ("urlencoded");
            builder.begin_array ();
            foreach (var pair in request.request_body.get_as_urlencoded ()) {
                builder.begin_object ();
                builder.set_member_name ("key");
                builder.add_string_value (pair.key);
                builder.set_member_name ("value");
                builder.add_string_value (pair.val);
                builder.end_object ();
            }
            builder.end_array (); // Urlencoded
            builder.set_member_name ("raw");
            builder.add_string_value (request.request_body.content);
            builder.end_object (); // body
        }

        private void serialize_request (Models.Request request) {
            builder.begin_object ();
            builder.set_member_name ("id");
            builder.add_int_value (request.id);
            builder.set_member_name ("name");
            builder.add_string_value (request.name);
            builder.set_member_name ("uri");
            builder.add_string_value (request.uri);
            builder.set_member_name ("method");
            builder.add_int_value (request.method.to_i ());
            if (request.last_sent != null) {
                builder.set_member_name ("last_sent");
                builder.add_int_value (request.last_sent.to_unix ());
            }
            builder.set_member_name ("script");
            builder.add_string_value (request.script_code);

            if (request.collection_id != null) {
                builder.set_member_name ("collection_id");
                builder.add_int_value (request.collection_id);
            }

            serialize_headers (request);
            serialize_body (request);

            builder.end_object ();
        }

        private void serialize_collection (Models.Collection collection) {
            builder.begin_object ();
            builder.set_member_name ("id");
            builder.add_int_value (collection.id);
            builder.set_member_name ("name");
            builder.add_string_value (collection.name);
            builder.set_member_name ("items_visible");
            // builder.add_boolean_value (collection.items_visible); Deprecated

            builder.end_object ();
        }

        public void serialize (Gee.ArrayList<Models.Request> items,
                               Gee.ArrayList<Models.Collection> collections) {
            builder.begin_object ();
            builder.set_member_name ("version");
            builder.add_string_value ("0.2");

            builder.set_member_name ("collections");
            builder.begin_array ();

            foreach (var collection in collections) {
                serialize_collection (collection);
            }

            builder.end_array ();
            builder.set_member_name ("request_items");
            builder.begin_array ();

            foreach (var item in items) {
                serialize_request (item);
            }

            builder.end_array ();
            builder.end_object ();

            var generator = new Json.Generator ();
            generator.set_root (builder.get_root ());

            data = generator.to_data (null);
        }

        public void write_to_file (string filepath) {
            var file = File.new_for_path (filepath);

            try {
                // Test for the existence of file
                if (file.query_exists ()) {
                    file.delete ();
                }

                var data_stream = new DataOutputStream (file.create (FileCreateFlags.REPLACE_DESTINATION));
                data_stream.put_string (data);
            } catch (IOError e) {
                string dir_path = Path.get_dirname (filepath);

                File dir = File.new_for_path (dir_path);
                dir.make_directory_with_parents ();
                write_to_file (filepath);
            } catch (Error e) {
                stderr.printf ("Error during saving settings: %s\n", e.message);
            }
        }
    }
}
