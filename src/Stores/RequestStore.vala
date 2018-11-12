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
    public class RequestStore {
        public Gee.ArrayList<RequestItem> items { get; private set; }

        public RequestStore () {
            items = new Gee.ArrayList<RequestItem> ();
        }

        public void add_request (RequestItem item) {
            items.add (item);
        }

        public int index_of (RequestItem item) {
            return items.index_of (item);
        }

        public RequestItem get_request (int idx) {
            return items.@get (idx);
        }

        public void update_request (int idx, RequestItem item) {
            items.insert (idx, item);
        }

        public bool destroy (RequestItem item) {
            if (items.contains(item)) {
                items.remove (item);
                return true;
            }
            return false;
        }
    }
}
