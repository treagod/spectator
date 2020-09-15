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
        public abstract bool delete_request (uint id);
        public abstract bool set_collection_id_for_request (uint request_id, uint collection_id);
        public abstract Models.Request? get_request_by_id (uint id);
    }

    public class TestRequestService : IRequestService, Object {
        private Gee.ArrayList<Models.Request> requests;

        public signal void request_added (Models.Request request);
        public signal void request_deleted (uint id);

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

        public bool delete_request (uint id) {
            foreach (var request in this.requests) {
                if (request.id == id) {
                    this.requests.remove (request);
                    this.request_deleted (id);
                    return true;
                }
            }

            return false;
        }

        public bool set_collection_id_for_request (uint request_id, uint collection_id) {
            var request = this.get_request_by_id (request_id);

            if (request != null) {
                request.collection_id = collection_id;
                return true;
            } else {
                return false;
            }
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
        public abstract void delete_request (uint id);
        public abstract void move_request (uint target_id, uint moved_id);
        public abstract void move_request_to_begin (uint moved_id);
        public abstract void move_request_to_end (uint moved_id);
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

        public void delete_request (uint id) {
            foreach (var entry in this.custom_order_entries) {
                if (entry.id == id && entry.type == Order.Type.REQUEST) {
                    this.custom_order_entries.remove (entry);
                    break;
                }
            }
        }

        public void move_request (uint target_id, uint moved_id) {
            var idx = 0;
            this.remove_request (moved_id);

            for (int i = 0; i < this.custom_order_entries.size; i++) {
                var entry = this.custom_order_entries.get (i);
                if (entry.id == target_id && entry.type == Order.Type.REQUEST) {
                    idx = i;
                    break;
                }
            }

            this.custom_order_entries.insert (idx + 1, new Order (moved_id, Order.Type.REQUEST));
        }

        private void remove_request (uint id) {
            foreach (var entry in this.custom_order_entries) {
                if (entry.id == id && entry.type == Order.Type.REQUEST) {
                    this.custom_order_entries.remove (entry);
                    return;
                }
            }
        }

        public void move_request_to_end (uint moved_id) {
            this.remove_request (moved_id);
            this.custom_order_entries.add (new Order (moved_id, Order.Type.REQUEST));
        }

        public void move_request_to_begin (uint moved_id) {
            this.remove_request (moved_id);
            this.custom_order_entries.insert (0, new Order (moved_id, Order.Type.REQUEST));
        }
    }

    public interface ICollectionService : Object {
        public abstract Gee.ArrayList<Models.Collection> get_collections ();
        public abstract bool add_collection (Models.Collection collection);
        public abstract bool add_request_to_collection (uint collection, uint request_id);
        public abstract bool add_request_to_collection_begin (uint collection, uint request_id);
        public abstract Models.Collection? get_collection_by_id (uint id);
        public abstract void append_after_request_to_collection (uint collection_id, uint target_id, uint moved_id);
    }

    public class TestCollectionService : ICollectionService, Object {
        private Gee.ArrayList<Models.Collection> collections;
        private IRequestService request_service;

        public signal void collection_added (Models.Collection collection);

        public TestCollectionService (IRequestService request_service) {
            this.collections = new Gee.ArrayList<Models.Collection> ();
            this.request_service = request_service;
        }
        public Gee.ArrayList<Models.Collection> get_collections () {
            return this.collections;
        }

        public bool add_request_to_collection_begin (uint collection_id, uint request_id) {
            var collection = this.get_collection_by_id (collection_id);

            if (collection != null) {
                collection.request_ids.insert (0, request_id);
                this.request_service.set_collection_id_for_request (request_id, collection_id);
            } else {
                return false;
            }

            return true;
        }

        public bool add_request_to_collection (uint collection_id, uint request_id) {
            var collection = this.get_collection_by_id (collection_id);

            if (collection != null) {
                collection.add_request_id (request_id);
                this.request_service.set_collection_id_for_request (request_id, collection_id);
            } else {
                return false;
            }

            return true;
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

        public void append_after_request_to_collection (uint collection_id, uint target_id, uint moved_id) {
            var idx = 0;
            var collection = this.get_collection_by_id (collection_id);

            collection.request_ids.remove (moved_id);

            // Get position to insert after
            for (var i = 0; i < collection.request_ids.size; i++) {
                if (collection.request_ids[i] == target_id) {
                    idx = i;
                    break;
                }
            }
            collection.request_ids.insert (idx + 1, moved_id);
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
                var rs = new TestRequestService ();
                var cs = new TestCollectionService (rs);
                var os = new TestOrderService ();

                cs.collection_added.connect ((collection) => {
                    os.append_item (collection.id, Order.Type.COLLECTION);
                });

                rs.request_added.connect ((request) => {
                    os.append_item (request.id, Order.Type.REQUEST);
                });

                rs.request_deleted.connect ((id) => {
                    os.delete_request (id);
                });

                var request = new Models.Request ("My Request", Models.Method.POST);
                request.uri = "http://zeit.de";
                request.script_code = "// function before_sending(request) {\n// }";

                rs.add_request (request);

                var col = new Models.Collection ("My Collection");

                cs.add_collection (col);

                request = new Models.Request ("Pokemon Gen 3", Models.Method.GET);
                request.uri = "https://pokeapi.co/api/v2/generation/3/";
                request.last_sent = new DateTime.now_local ();

                rs.add_request (request);

                request = new Models.Request ("Pokemon Gen 2", Models.Method.GET);
                request.uri = "https://pokeapi.co/api/v2/generation/2/";
                var time = new DateTime.now_local ();
                time = time.add_days(-1);
                time = time.add_minutes(-1);
                request.last_sent = time;

                rs.add_request (request);

                cs.add_request_to_collection (col.id, request.id);

                var window = new Spectator.Window(this, rs, cs, os);
                this.add_window (window);

                window.show_all ();
                running = true;
            }
        }
    }
}
