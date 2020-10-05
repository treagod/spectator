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

namespace Spectator {
    public class SendingService : Object {
        private Gee.HashMap<uint, ResponseItem> responses;

        public SendingService () {
            this.responses = new Gee.HashMap<uint, ResponseItem> ();
        }

        public signal void finished_request (Models.Request request, ResponseItem response);
        public signal void response_chunk (Models.Request request, ResponseItem response);

        public bool request_was_sent (uint id) {
            return this.responses.has_key (id);
        }

        public ResponseItem? get_response (uint id) {
            return this.responses[id];
        }

        public async void send_request (Models.Request request) {
            var action = new Services.RequestAction (request);
            action.make_request.begin ();

            action.request_got_chunk.connect  ((res) => {
                this.responses[request.id] = res;
            });

            action.finished_request.connect ((res) => {
                this.responses[request.id] = res;
                this.finished_request (request, res);
            });
        }
    }
}
