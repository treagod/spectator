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

namespace Spectator {
    public class ResponseItem {
        public string url { get; set; }
        public string raw { get; set; }
        public string data { get; set; }
        public uint status_code { get; set; }
        public double duration { get; set; }
        public int64 size { get; set; }
        public uint redirects { get; set; }

        public Gee.HashMap<string, string> headers { get; private set; }

        public ResponseItem () {
            headers = new Gee.HashMap<string, string> ();
        }

        public void add_header (string key, string val) {
            headers[key] = val;
        }
    }
}
