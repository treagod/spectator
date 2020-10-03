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
    public class RequestBody {
        public ContentType type;
        /* Deprecated */
        public Gee.ArrayList<Pair> form_data { get; private set; }
        /* Deprecated */
        public Gee.ArrayList<Pair> urlencoded { get; private set; }
        /* Deprecated */
        public string raw;
        public string content;

        public RequestBody () {
            raw = "";
            this.content = "";
            type = FORM_DATA;
            form_data = new Gee.ArrayList<Pair> ();
            urlencoded = new Gee.ArrayList<Pair> ();
        }

        public void add_key_value (Pair pair) {
            if (type == FORM_DATA) {
                form_data.add (pair);
            } else if (type == URLENCODED) {
                urlencoded.add (pair);
            }
        }

        public void update_key_value (Pair pair) {
            if (type == FORM_DATA) {
                if (form_data.contains (pair)) {
                    // do something..
                }
            } else if (type == URLENCODED) {
                if (urlencoded.contains (pair)) {
                    // do something..
                }
            }
        }

        public void remove_key_value (Pair pair) {
            if (type == FORM_DATA) {
                form_data.remove (pair);
            } else if (type == URLENCODED) {
                urlencoded.remove (pair);
            }
        }

        public enum ContentType {
            FORM_DATA, URLENCODED, PLAIN, JSON, XML, HTML;

            public static ContentType convert (int i) {
                switch (i) {
                    case 0:
                    return ContentType.FORM_DATA;
                    case 1:
                    return ContentType.URLENCODED;
                    case 2:
                    return ContentType.PLAIN;
                    case 3:
                    return ContentType.JSON;
                    case 4:
                    return ContentType.XML;
                    case 5:
                    return ContentType.HTML;
                    default:
                    assert_not_reached ();
                }
            }

            public int to_i () {
                switch (this) {
                    case ContentType.FORM_DATA:
                    return 0;
                    case ContentType.URLENCODED:
                    return 1;
                    case ContentType.PLAIN:
                    return 2;
                    case ContentType.JSON:
                    return 3;
                    case ContentType.XML:
                    return 4;
                    case ContentType.HTML:
                    return 5;
                    default:
                    assert_not_reached ();
                }
            }

            public static string to_mime (ContentType type) {
                switch (type) {
                    case ContentType.FORM_DATA:
                    return "multipart/form-data";
                    case ContentType.URLENCODED:
                    return "application/x-www-form-urlencoded";
                    case ContentType.PLAIN:
                    return "text/plain";
                    case ContentType.JSON:
                    return "application/json";
                    case ContentType.XML:
                    return "application/xml";
                    case ContentType.HTML:
                    return "application/html";
                    default:
                    assert_not_reached ();
                }
            }
        }
    }
}
