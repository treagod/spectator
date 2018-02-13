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

namespace HTTPInspector {
    class ResponseView : Gtk.Box {
        private Gtk.ScrolledWindow scrolled;
        private ResponseText response;
        private ResponseStatusBar status_bar;

        construct {
            orientation = Gtk.Orientation.VERTICAL;

            status_bar = new ResponseStatusBar ();

            pack_start (status_bar, false, false, 15);
        }

        public ResponseView () {
            scrolled = new Gtk.ScrolledWindow (null, null);
            response = new ResponseText ();


            scrolled.add (response);

            pack_start (scrolled);
        }

        public void update_response (ResponseItem? it) {
            response.insert (it);
            status_bar.update (it);
        }

        public void reset () {
            response = new ResponseText ();
        }
    }
}
