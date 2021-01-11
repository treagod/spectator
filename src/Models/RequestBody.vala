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

namespace Spectator {
    public class RequestBody {
        public ContentType type;
        public string content;

        public RequestBody () {
            this.content = "";
            this.type = FORM_DATA;
        }

        public void add_key_value (Pair pair) {
            //  if (type == FORM_DATA) {
            //      form_data.add (pair);
            //  } else if (type == URLENCODED) {
            //      urlencoded.add (pair);
            //  }
        }

        public Gee.ArrayList<Pair> get_as_form_data () {
            return deserialize_content ();
        }

        private Gee.ArrayList<Pair> deserialize_content () {
            var pairs = new Gee.ArrayList<Pair> ();
            var pair_strings = content.split("\n");

            foreach (var pair in pair_strings) {
                if (pair.strip ().length > 0) {
                    var key_value = pair.split(">>|<<");
                    pairs.add (new Pair(key_value[0], key_value[1]));
                }
            }

            return pairs;
        }

        public Gee.ArrayList<Pair> get_as_urlencoded () {
            return deserialize_content ();
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
