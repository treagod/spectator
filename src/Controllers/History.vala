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

namespace Spectator.Controllers {
    public class History {
        private unowned Main main;
        private Gee.ArrayQueue<Models.Request> requests;
        private Widgets.Sidebar.History.Container view;

        public History (Main m, Widgets.Sidebar.History.Container history_view) {
            main = m;
            view = history_view;
            requests = new Gee.ArrayQueue<Models.Request> ();
        }

        public void add (Models.Request request) {
            if (!requests.contains (request)) {
                requests.offer_head (request);
            } else {
                // Move the request to the head of the queue
                requests.remove (request);
                requests.offer_head (request);
            }

            view.clear ();

            foreach (var req in requests) {
                view.add_request (req);
            }
        }
    }
}
