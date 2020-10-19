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

namespace Spectator.Services {
    public class JsonDeserializer {
        public signal void request_loaded (Models.Request request);
        public signal void collection_loaded (Models.Collection collection);
        public signal void request_added_to_collection (Models.Collection collection, Models.Request request);

        public void load_data_from_file (string filepath) {
            var parser = new Json.Parser ();
            try {
                var file = File.new_for_path (filepath);

                if (file.query_exists ()) {
                    // Open file for reading and wrap returned FileInputStream into a
                    // DataInputStream, so we can read line by line
                    var dis = new DataInputStream (file.read ());
                    string line;
                    var builder = new StringBuilder ();
                    // Read lines until end of file (null) is reached
                    while ((line = dis.read_line (null)) != null) {
                        builder.append (line);
                    }

                    parser.load_from_data (builder.str);
                    var object = parser.get_root ().get_object ();

                    var version = object.get_string_member ("version");

                    if (version == "0.2") {
                        load_v2 (object);
                    } else if (version == "0.1") {
                        load_v1 (object);
                    } else {
                        stderr.printf ("Saved data was corrupted. Could not load data\n");
                    }
                }
            } catch (Error e) {
                stderr.printf ("Error during loading settings: %s\n", e.message);
            }
        }

        private void load_v1 (Json.Object object) {
            var request_items = object.get_array_member ("request_items");
            var collection = new Models.Collection (_("Unnamed collection"));
            collection_loaded (collection);

            foreach (var request_item in request_items.get_elements ()) {
                var request = deserialize_item_v1 (request_item.get_object ());
                // collection.add_request (request);
                request_added_to_collection (collection, request);
            }
        }

        private Models.Request deserialize_item_v1 (Json.Object request_object) {
            var name = request_object.get_string_member ("name");
            var uri = request_object.get_string_member ("uri");
            var method = (int) request_object.get_int_member ("method");
            var script_code = "";
            if (request_object.has_member ("script")) {
                script_code = request_object.get_string_member ("script");
            }
            var request = new Models.Request.with_uri (name, uri, Models.Method.convert (method));
            var headers = request_object.get_array_member ("headers");

            request.script_code = script_code;

            foreach (var header_element in headers.get_elements ()) {
                var header = header_element.get_object ();
                request.add_header (new Pair (header.get_string_member ("key"), header.get_string_member ("value")));
            }

            var body = request_object.get_object_member ("body");

            request.request_body.type = RequestBody.ContentType.FORM_DATA;
            foreach (var form_data_element in body.get_array_member ("form_data").get_elements ()) {
                var form_data_item = form_data_element.get_object ();
                request.request_body.add_key_value (new Pair (
                        form_data_item.get_string_member ("key"),
                        form_data_item.get_string_member ("value")
                ));
            }

            request.request_body.type = RequestBody.ContentType.URLENCODED;
            foreach (var form_data_element in body.get_array_member ("urlencoded").get_elements ()) {
                var form_data_item = form_data_element.get_object ();
                request.request_body.add_key_value (new Pair (
                        form_data_item.get_string_member ("key"),
                        form_data_item.get_string_member ("value")
                ));
            }

            request.request_body.type =
                    RequestBody.ContentType.convert ((int) body.get_int_member ("active_type"));

            request.request_body.content = body.get_string_member ("raw") ?? "";

            return request;
        }

        private void load_v2 (Json.Object object) {
            var requests = new Gee.ArrayList<Models.Request> ();
            var items = object.get_member ("request_items");
            var request_items = items.get_array ();

            foreach (var request_item in request_items.get_elements ()) {
                var request = deserialize_item (request_item.get_object ());

                requests.add (request);
            }


            var collection_array = object.get_array_member ("collections");
            foreach (var collection_element in collection_array.get_elements ()) {
                var collection = deserialize_collection (collection_element.get_object ());
                var old_id = collection.id;

                collection_loaded (collection);

                foreach (var req in requests) {
                    if (req.collection_id == old_id) {
                        this.request_added_to_collection (collection, req);
                    }
                }
            }
        }

        private Models.Collection deserialize_collection (Json.Object collection_object) {
            var id = (uint) collection_object.get_int_member ("id");
            var name = collection_object.get_string_member ("name");

            var collection = new Models.Collection.with_id (id, name);

            return collection;
        }

        private Models.Request deserialize_item (Json.Object request_object) {
            var name = request_object.get_string_member ("name");
            var uri = request_object.get_string_member ("uri");
            var method = (int) request_object.get_int_member ("method");
            var script_code = "";
            if (request_object.has_member ("script")) {
                script_code = request_object.get_string_member ("script");
            }
            Models.Request request;

            if (request_object.has_member ("id")) {
                var id = (uint) request_object.get_int_member ("id");
                request = new Models.Request.with_uri_and_id (id, name, uri, Models.Method.convert (method));
            } else {
                request = new Models.Request.with_uri (name, uri, Models.Method.convert (method));
            }

            if (request_object.has_member ("last_sent")) {
                int64 last_sent = request_object.get_int_member ("last_sent");
                request.last_sent = new DateTime.from_unix_local (last_sent);
            }

            if (request_object.has_member ("collection_id")) {
                request.collection_id = (uint) request_object.get_int_member ("collection_id");
            }
            var headers = request_object.get_array_member ("headers");

            request.script_code = script_code;

            foreach (var header_element in headers.get_elements ()) {
                var header = header_element.get_object ();
                request.add_header (new Pair (header.get_string_member ("key"), header.get_string_member ("value")));
            }

            var body = request_object.get_object_member ("body");

            request.request_body.type = RequestBody.ContentType.FORM_DATA;
            foreach (var form_data_element in body.get_array_member ("form_data").get_elements ()) {
                var form_data_item = form_data_element.get_object ();
                request.request_body.add_key_value (new Pair (
                        form_data_item.get_string_member ("key"),
                        form_data_item.get_string_member ("value")
                ));
            }

            request.request_body.type = RequestBody.ContentType.URLENCODED;
            foreach (var form_data_element in body.get_array_member ("urlencoded").get_elements ()) {
                var form_data_item = form_data_element.get_object ();
                request.request_body.add_key_value (new Pair (
                        form_data_item.get_string_member ("key"),
                        form_data_item.get_string_member ("value")
                ));
            }

            request.request_body.type =
                    RequestBody.ContentType.convert ((int) body.get_int_member ("active_type"));

            request.request_body.content = body.get_string_member ("raw") ?? "";

            return request;
        }
    }
}
