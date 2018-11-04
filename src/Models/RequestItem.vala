/*
* Copyright (c) 2018 Marvin Ahlgrimm (https://github.com/treagod)
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

namespace HTTPInspector {
    public class RequestItem : Object  {
        public string name { get; set; }
        private string _raw_uri { get; set; }
        private Soup.URI? _uri { get; set; }
        public RequestBody request_body { get; private set; }
        public Method method { get; set; }
        public RequestStatus status { get; set; }
        public ResponseItem? response { get; set; }
        public Gee.ArrayList<Pair> headers { get; private set; }
        public string query {
            get {
                if (_uri == null || _uri.query == null) {
                    return "";
                }
                return _uri.query;
            } public set {
                _uri.set_query (value);
                _raw_uri = _uri.to_string (false);
            }
        }

        public string uri {
            get {
               return _raw_uri;
            }
            set {
                _uri = new Soup.URI (value);
               _raw_uri = value;
            }
        }

        public RequestItem (string nam, Method meth) {
            headers = new Gee.ArrayList<Pair> ();
            name = nam;
            uri = "";
            method = meth;
            status = RequestStatus.NOT_SENT;
        }

        public RequestItem.with_uri (string nam, string url, Method meth) {
            headers = new Gee.ArrayList<Pair> ();
            name = nam;
            uri = url;
            method = meth;
            status = RequestStatus.NOT_SENT;
        }

        public void update_header (int i, string key, string val) {
            if (headers.size > i && headers.size != 0) {
                var header = headers.@get (i);
                header.key = key;
                header.val = val;
            } else {
                //Index does not exist, create new entry;
                add_header (new Pair (key, val));
            }
        }

        public bool has_valid_uri () {
            return _uri != null;
        }

        public void add_header (Pair header) {
            headers.add (header);
        }

        public void remove_header (Pair header) {
            headers.remove (header);
        }
    }

    public enum RequestStatus {
        NOT_SENT, SENT, SENDING
    }

    public enum Method {
        GET, POST, PUT, PATCH, DELETE, HEAD;

        public static Method convert (int i) {
            switch (i) {
                case 0:
                    return GET;
                case 1:
                    return POST;
                case 2:
                    return PUT;
                case 3:
                    return PATCH;
                case 4:
                    return DELETE;
                case 5:
                    return HEAD;
                default:
                    assert_not_reached ();
            }
        }

        public int to_i () {
            switch (this) {
                case GET:
                    return 0;
                case POST:
                    return 1;
                case PUT:
                    return 2;
                case PATCH:
                    return 3;
                case DELETE:
                    return 4;
                case HEAD:
                    return 5;
                default:
                    assert_not_reached ();
            }
        }

        public string to_str () {
            switch (this) {
                case GET:
                    return "GET";
                case POST:
                    return "POST";
                case PUT:
                    return "PUT";
                case PATCH:
                    return "PATCH";
                case DELETE:
                    return "DELETE";
                case HEAD:
                    return "HEAD";
                default:
                    assert_not_reached ();
            }
        }
    }
}
