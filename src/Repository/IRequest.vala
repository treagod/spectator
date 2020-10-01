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
    public interface IRequestUpdater : Object {
        public abstract void update_name (string name);
        public abstract void update_script (string script);
        public abstract void update_method (Models.Method method);
        public abstract void update_url (string url);
        public abstract void update_headers (Gee.ArrayList<Pair> headers);
        public abstract void update_last_sent (DateTime last_sent);
    }

    public delegate void UpdateCallback (IRequestUpdater updater);

    public interface IRequest : Object {
        public abstract Gee.ArrayList<Models.Request> get_requests ();
        public abstract bool add_request (Models.Request request);
        public abstract void update_request (uint id, UpdateCallback cb);
        public abstract bool delete_request (uint id);
        public abstract Models.Request? get_request_by_id (uint id);
    }
}
