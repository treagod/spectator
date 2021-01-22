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

namespace Spectator.Widgets.Request {
    public interface Interface {
        public signal void url_changed (string url);
        public signal void method_changed (Models.Method method);
        public signal void request_activated ();
        public signal void cancel_process ();
        public signal void header_added (Gee.ArrayList<Pair> headers);
        public signal void header_deleted (Gee.ArrayList<Pair> headers);
        public signal void url_params_updated (Gee.ArrayList<Pair> items);
    }
}
