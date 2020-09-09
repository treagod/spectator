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
    public interface IRequestService : Object {
        public abstract Gee.ArrayList<Models.Request> get_requests ();
        public abstract bool add_request (Models.Request request);
        public abstract Models.Request? get_request_by_id (uint id);
    }

    public class TestRequestService : IRequestService, Object {
        private Gee.ArrayList<Models.Request> requests;

        public signal void request_added (Models.Request request);

        public TestRequestService () {
            this.requests = new Gee.ArrayList<Models.Request> ();
        }
        public Gee.ArrayList<Models.Request> get_requests () {
            return this.requests;
        }

        public bool add_request (Models.Request request) {
            this.requests.add (request);
            this.request_added (request);

            return true;
        }

        public Models.Request? get_request_by_id (uint id) {
            Models.Request request = null;

            foreach (var req in this.requests) {
                if (req.id == id) {
                    request = req;
                    break;
                }
            }

            return request;
        }
    }

    public class Order {
        public enum Type {
            REQUEST,
            COLLECTION
        }

        public Type type;
        public uint id;

        public Order (uint id, Type type) {
            this.type = type;
            this.id = id;
        }
    }

    public interface IOrderService : Object {
        public abstract Gee.ArrayList<Order> get_order ();
        public abstract void append_item (uint id, Order.Type type);
    }

    public class TestOrderService : IOrderService, Object {
        Gee.ArrayList<Order> custom_order_entries;

        public TestOrderService () {
            this.custom_order_entries = new Gee.ArrayList<Order> ();
        }

        public Gee.ArrayList<Order> get_order () {
            return this.custom_order_entries;
        }

        public void append_item (uint id, Order.Type type) {
            this.custom_order_entries.add(new Order(id, type));
        }
    }

    public interface ICollectionService : Object {
        public abstract Gee.ArrayList<Models.Collection> get_collections ();
        public abstract bool add_collection (Models.Collection collection);
        public abstract Models.Collection? get_collection_by_id (uint id);
    }

    public class TestCollectionService : ICollectionService, Object {
        private Gee.ArrayList<Models.Collection> collections;

        public signal void collection_added (Models.Collection collection);


        public TestCollectionService () {
            this.collections = new Gee.ArrayList<Models.Collection> ();
        }
        public Gee.ArrayList<Models.Collection> get_collections () {
            return this.collections;
        }

        public bool add_collection (Models.Collection collection) {
            this.collections.add (collection);
            this.collection_added (collection);
            return true;
        }

        public Models.Collection? get_collection_by_id (uint id) {
            Models.Collection collection = null;

            foreach (var col in this.collections) {
                if (col.id == id) {
                    collection = col;
                    break;
                }
            }

            return collection;
        }
    }

    public class Application : Gtk.Application {
        // Avoid multiple instances
        public bool running = false;
        construct {
            flags |= ApplicationFlags.HANDLES_OPEN;
            application_id = "com.github.treagod.spectator";
        }

        protected override void activate () {
            if (!running) {
                var cs = new TestCollectionService ();
                var rs = new TestRequestService ();
                var os = new TestOrderService ();

                cs.collection_added.connect ((collection) => {
                    os.append_item (collection.id, Order.Type.COLLECTION);
                });

                rs.request_added.connect ((request) => {
                    os.append_item (request.id, Order.Type.REQUEST);
                });

                var request = new Models.Request ("My Request", Models.Method.GET);
                request.uri = "http://zeit.de";
                request.script_code = "// function before_sending(request) {\n// }";

                rs.add_request (request);

                cs.add_collection (new Models.Collection ("My Collection"));

                request = new Models.Request ("Pokemon Gen 3", Models.Method.POST);
                request.uri = "https://pokeapi.co/api/v2/generation/3/";

                rs.add_request (request);

                var window = new Spectator.Window(this, rs, cs, os);
                this.add_window (window);

                window.show_all ();
                running = true;
            }
        }
    }
}
