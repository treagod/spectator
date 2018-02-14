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
    public enum Method {
        GET, POST, PUT, PATCH, DELETE, HEAD;

        public static Method convert(int i) {
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
    }

    public enum RequestStatus {
        NOT_SENT, SENT, SENDING
    }

    public class RequestItem  {

        public string name { get; set; }
        public string domain { get; set; }
        public string subdomain { get; set; }
        public string path { get; set; }
        public Method method { get; set; }
        public RequestStatus status { get; set; }
        public ResponseItem response { get; set; }
        public Gee.ArrayList<Header> headers { get; private set; }
        public string user_agent { get; private set; }

        public RequestItem(string nam, Method meth) {
            headers = new Gee.ArrayList<Header> ();
            user_agent = "http-inspector/0.1";
            name = nam;
            domain = "";
            subdomain = "";
            path = "";
            method = meth;
            status = RequestStatus.NOT_SENT;
        }

        public RequestItem.with_url(string nam, string url, Method meth) {
            headers = new Gee.ArrayList<Header> ();
            user_agent = "http-inspector/0.1";
            name = nam;
            domain = url;
            subdomain = url;
            path = url;
            method = meth;
            status = RequestStatus.NOT_SENT;
        }

        public void update_header (int i, string key, string val) {
            if (headers.size > i && headers.size != 0) {
                if (key == "User-Agent") {
                    user_agent = val;
                } else if (headers.@get (i).key == "User-Agent") {
                    // User Agent was resetted -> set it to default
                    user_agent = "http-inspector/0.1";
                }
                var header = headers.@get (i);
                header.key = key;
                header.val = val;
            } else {
                // Index does not exist, create new entry;
                add_header (key, val);
            }
        }

        public void add_header (string key, string val) {
            if (key == "User-Agent") {
                user_agent = val;
            }

            headers.add (new Header (key, val));
        }
    }
}
