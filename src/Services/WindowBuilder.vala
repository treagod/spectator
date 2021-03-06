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

namespace Spectator.Services {
    public class WindowBuilder {
        private Window window;
        private Repository.IRequest request_repository;
        private Repository.ICollection collection_repository;
        private Repository.ICustomOrder order_repository;
        private Repository.IEnvironment environment_repository;
        public WindowBuilder (Repository.IRequest rr,
            Repository.ICollection cr,
            Repository.ICustomOrder or,
            Repository.IEnvironment er) {
            request_repository = rr;
            collection_repository = cr;
            order_repository = or;
            environment_repository = er;
        }

        public Window build_window (Gtk.Application app) {
            window = new Window (app, request_repository, collection_repository, order_repository, environment_repository);
            return window;
        }
    }
}