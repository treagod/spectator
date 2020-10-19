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

namespace Spectator.Models {
    public class Collection {
        public Gee.ArrayList<uint> request_ids { get; private set; }
        public string name { get; set; }
        public uint id { get; set; }
        private static uint max_id = 0; /* Deprected: move id generation out of model */

        public Collection (string nam) {
            this.id = max_id++;
            this.name = nam;
            this.request_ids = new Gee.ArrayList<uint> ();
        }

        public Collection.with_id (uint i, string nam) {
            if (i >= max_id) {
                max_id = i;
                this.id = max_id++;
            } else {
                this.id = i;
            }

            this.name = nam;
            this.request_ids = new Gee.ArrayList<uint> ();
        }

        public void add_request_id (uint id) {
            if (!this.request_ids.contains (id)) {
                this.request_ids.add (id);
            }
        }

        public void remove_request (uint id) {
            if (this.request_ids.contains (id)) {
                this.request_ids.remove (id);
            }
        }
    }
}
