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


namespace Spectator.Repository {
    public interface ICustomOrder : Object {
        public abstract Gee.ArrayList<Models.Order> get_order ();
        public abstract void move_request_after_request (uint target_id, uint moved_id);
        public abstract void move_request_to_begin (uint moved_id);
        public abstract void move_request_to_end (uint moved_id);
        public abstract bool add_request_to_collection_begin (uint collection, uint request_id);
        public abstract void append_after_request_to_collection_requests (uint collection_id, uint target_id, uint moved_id);
    }
}
