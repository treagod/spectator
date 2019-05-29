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

namespace Spectator.Models {
    public class Collection {
        private Gee.ArrayList<Request> requests;
        public string name { get; private set; }
        public uint id { get; private set; }
        private static uint max_id = 0;

        public Collection (string nam) {
            id = max_id++;
            name = nam;
            requests = new Gee.ArrayList<Request> ();
        }

        public Collection.with_id (uint i, string nam) {
            if (i > max_id) {
                max_id = i;
                id = max_id++;
            } else {
                id = i;
            }

            name = nam;
            requests = new Gee.ArrayList<Request> ();
        }

        public void add_request (Request request) {
            if (!requests.contains (request)) {
                requests.add (request);
            }
        }
    }
}